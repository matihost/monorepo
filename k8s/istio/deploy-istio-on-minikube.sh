#!/usr/bin/env bash

function ensureIstioPackageDownloaded() {
  [ -e ~/.istio/current ] || {
    mkdir -p ~/.istio
    cd ~/.istio || exit 1
    curl -sL https://istio.io/downloadIstio | sh -
    cd istio-* || exit 1
    ln -s "$(pwd)" ../current
  }
}

function installIstioOperator() {
  helm upgrade --install istio-operator ~/.istio/current/manifests/charts/istio-operator \
    --set hub=docker.io/istio \
    --set tag=1.8.2
}

function deploySampleApp() {

  kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: ingress
  namespace: default
spec:
  ingressClassName: istio
  rules:
  - host: httpbin.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          serviceName: httpbin
          servicePort: 8000
EOF
}

function installIstioProfile() {
  kubectl create ns istio-system

  kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: IngressClass
metadata:
  # annotations:
  #   ingressclass.kubernetes.io/is-default-class: "true
  name: istio
spec:
  controller: istio.io/ingress-controller
EOF

  kubectl apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: default:privileged
  namespace: istio-system
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: psp:privileged
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: Group
  name: system:serviceaccounts:istio-system
EOF

  kubectl apply -f - <<EOF
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
metadata:
  namespace: istio-system
  name: istiocontrolplane
spec:
  profile: default
  components:
    cni:
      enabled: true
  values:
    cni:
      excludeNamespaces:
       - istio-system
       - kube-system
      logLevel: info
    gateways:
      istio-ingressgateway:
        type: LoadBalancer
        autoscaleMax: "20"
        # serviceAnnotations:
        #   service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
        #   service.beta.kubernetes.io/aws-load-balancer-backend-protocol: "http"
        #   service.beta.kubernetes.io/aws-load-balancer-connection-idle-timeout: "60"
EOF

  kubectl apply -f - <<EOF
apiVersion: policy/v1beta1
kind: PodSecurityPolicy
metadata:
  name: psp-host
  namespace: istio-system
spec:
  allowPrivilegeEscalation: true
  fsGroup:
      rule: RunAsAny
  hostNetwork: true
  runAsUser:
      rule: RunAsAny
  seLinux:
      rule: RunAsAny
  supplementalGroups:
      rule: RunAsAny
  volumes:
  - secret
  - configMap
  - emptyDir
  - hostPath
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: psp-host
  namespace: istio-system
rules:
- apiGroups:
  - policy
  resourceNames:
  - psp-host
  resources:
  - podsecuritypolicies
  verbs:
  - use
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: psp-host
  namespace: istio-system
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: psp-host
subjects:
  - apiGroup: rbac.authorization.k8s.io
    kind: Group
    name: system:serviceaccounts:istio-system
EOF
}

function deploySampleAppWithK8SIngress() {

  # because sample app need to be run as root
  kubectl apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: default:privileged
  namespace: default
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: psp:privileged
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: Group
  name: system:serviceaccounts:default
EOF

  mkdir -p /tmp/istio-certs
  CN="httpbin.example.com"
  openssl req -x509 -sha256 -subj "/CN=${CN}" -days 365 -out "/tmp/istio-certs/${CN}.crt" -newkey rsa:2048 -nodes -keyout "/tmp/istio-certs/${CN}.key"
  kubectl create -n istio-system secret tls httpbin-credential --key="/tmp/istio-certs/${CN}.key" --cert="/tmp/istio-certs/${CN}.crt"

  # sidecar is not necessary when only Ingress is used from istio
  kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    # this is not needed for k8s 1.18+ but istio seems not understand spec.ingressClassName
    kubernetes.io/ingress.class: istio
  name: httpbin
  namespace: default
spec:
  # ingressClassName: istio
  rules:
  - host: httpbin.example.com
    http:
      paths:
      - backend:
          service:
            name: httpbin
            port:
              number: 8000
        path: /
        pathType: Prefix
  # Istio support Ingresses with TLS but secret has to be in istio-system namespace
  tls:
  - hosts:
    - httpbin.example.com
    secretName: httpbin-credential
EOF

  # to enforce autosidecar injection in namespace
  # we do use Istion only as k8s Ingress controller
  # so it is not necessary
  # kubectl label namespace default istio-injection=enabled

  kubectl apply -f ~/.istio/current/samples/httpbin/httpbin.yaml
}

function exposeSampleAppViaIstioNatively() {
  # TLS certificates has to be in namespace where ingressgateway is deployed (istio-system)
  CN="api.example.com"
  openssl req -x509 -sha256 -subj "/CN=${CN}" -days 365 -out "/tmp/istio-certs/${CN}.crt" -newkey rsa:2048 -nodes -keyout "/tmp/istio-certs/${CN}.key"
  kubectl create -n istio-system secret tls api-credential --key="/tmp/istio-certs/${CN}.key" --cert="/tmp/istio-certs/${CN}.crt"
  CN="http.example.com"
  openssl req -x509 -sha256 -subj "/CN=${CN}" -days 365 -out "/tmp/istio-certs/${CN}.crt" -newkey rsa:2048 -nodes -keyout "/tmp/istio-certs/${CN}.key"
  kubectl create -n istio-system secret tls http-credential --key="/tmp/istio-certs/${CN}.key" --cert="/tmp/istio-certs/${CN}.crt"

  kubectl apply -f - <<EOF
apiVersion: networking.istio.io/v1beta1
kind: Gateway
metadata:
  name: api-gateway
  namespace: default
spec:
  selector:
    istio: ingressgateway # use Istio default gateway implementation
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - "api.example.com"
    - "http.example.com"
  - port:
      number: 443
      name: httphttps
      protocol: HTTPS
    tls:
      mode: SIMPLE
      credentialName: http-credential
    hosts:
    - http.example.com
  - port:
      number: 443
      name: apihttps
      protocol: HTTPS
    tls:
      mode: SIMPLE
      credentialName: api-credential
    hosts:
    - api.example.com
EOF
  kubectl apply -f - <<EOF
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: api-gateway-pathprefix
  namespace: default
spec:
  hosts:
  - "api.example.com"
  gateways:
  - default/api-gateway
  http:
  - match:
     - uri:
        prefix: /api/httpbin
    rewrite:
       uri: /
    route:
    - destination:
        port:
          number: 8000
        host: httpbin.default.svc.cluster.local
---
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: httpbin
  namespace: default
spec:
  hosts:
  - "http.example.com"
  gateways:
  - default/api-gateway
  - mesh # applies to all the sidecars in the mesh
  http:
  - route:
    - destination:
        port:
          number: 8000
        host: httpbin.default.svc.cluster.local
---
# Add timeout for internal service registry
# Notice lack of gateways - which means that it is applied only to sidecars in the mesh
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: httpbin-timeout
  namespace: default
spec:
  hosts:
  - httpbin.default.svc.cluster.local
  http:
  - timeout: 5s
    route:
    - destination:
        host: httpbin.default.svc.cluster.local
EOF

}

# Main
ensureIstioPackageDownloaded
installIstioOperator
installIstioProfile

deploySampleAppWithK8SIngress
exposeSampleAppViaIstioNatively
