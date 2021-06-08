#!/usr/bin/env bash
# usage for gke deployment: ./sample-http-server.sh gke shared1-dev
# usage for minikube deployment: ./sample-http-server.sh minikube

case $1 in
gke)
  MODE=gke
  CLUSTER_NAME="${2:?CLUSTER_NAME is required}"
  INTERNAL_DNS_SUFFIX="internal.gke.$(echo -n "${CLUSTER_NAME}" | sed 's/-/./g').gcp.testing"
  EXTERNAL_DNS_SUFFIX="external.gke.$(echo -n "${CLUSTER_NAME}" | sed 's/-/./g').gcp.testing"
  ;;
minikube)
  MODE=minikube
  INTERNAL_DNS_SUFFIX="internal.testing.minikube"
  ;;
*)
  echo "Mode minikube or gke only supported"
  exit 1
  ;;
esac

function deploySampleAppWithK8SIngress() {
  kubectl create ns sample-istio || echo "ignoring..."
  # to enforce autosidecar injection in namespace
  # we do use Istion only as k8s Ingress controller
  # so it is not necessary
  kubectl label namespace sample-istio istio-injection=enabled --overwrite

  # because sample app need to be run as root
  kubectl apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: sample-istio:privileged
  namespace: sample-istio
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: $([ "${MODE}" = "gke" ] && echo "gce:podsecuritypolicy:privileged" || echo "psp:privileged")
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: Group
  name: system:serviceaccounts:sample-istio
EOF

  mkdir -p /tmp/istio-certs
  CN="httpbin.${INTERNAL_DNS_SUFFIX}"
  openssl req -x509 -sha256 -subj "/CN=${CN}" -days 365 -out "/tmp/istio-certs/${CN}.crt" -newkey rsa:2048 -nodes -keyout "/tmp/istio-certs/${CN}.key"
  kubectl create -n istio-system secret tls httpbin-credential --key="/tmp/istio-certs/${CN}.key" --cert="/tmp/istio-certs/${CN}.crt"

  # sidecar is not necessary when only Ingress is used from istio
  kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  annotations:
    # this is not needed for k8s 1.18+ but istio seems not understand spec.ingressClassName
    kubernetes.io/ingress.class: istio
  name: httpbin
  namespace: sample-istio
spec:
  # ingressClassName: istio
  rules:
  - host: httpbin.${INTERNAL_DNS_SUFFIX}
    http:
      paths:
      - backend:
          serviceName: httpbin
          servicePort: 8000
        path: /
        pathType: Prefix
  # Istio support Ingresses with TLS but secret has to be in istio-system namespace
  tls:
  - hosts:
    - httpbin.${INTERNAL_DNS_SUFFIX}
    secretName: httpbin-credential
EOF

  kubectl apply -n sample-istio -f - <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: httpbin
---
apiVersion: v1
kind: Service
metadata:
  name: httpbin
  labels:
    app: httpbin
    service: httpbin
spec:
  ports:
  - name: http-httpbin
    port: 8000
    targetPort: 80
  selector:
    app: httpbin
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: httpbin
spec:
  replicas: 1
  selector:
    matchLabels:
      app: httpbin
      version: v1
  template:
    metadata:
      labels:
        app: httpbin
        version: v1
    spec:
      serviceAccountName: httpbin
      containers:
      - image: docker.io/kennethreitz/httpbin
        imagePullPolicy: IfNotPresent
        name: httpbin
        ports:
        - containerPort: 80
      securityContext:
        runAsUser: 0
EOF
}

function exposeSampleAppViaInternalIstioNatively() {
  # TLS certificates has to be in namespace where ingressgateway is deployed (istio-system)
  CN="api.${INTERNAL_DNS_SUFFIX}"
  openssl req -x509 -sha256 -subj "/CN=${CN}" -days 365 -out "/tmp/istio-certs/${CN}.crt" -newkey rsa:2048 -nodes -keyout "/tmp/istio-certs/${CN}.key"
  kubectl create -n istio-system secret tls api-credential --key="/tmp/istio-certs/${CN}.key" --cert="/tmp/istio-certs/${CN}.crt"
  CN="http.${INTERNAL_DNS_SUFFIX}"
  openssl req -x509 -sha256 -subj "/CN=${CN}" -days 365 -out "/tmp/istio-certs/${CN}.crt" -newkey rsa:2048 -nodes -keyout "/tmp/istio-certs/${CN}.key"
  kubectl create -n istio-system secret tls http-credential --key="/tmp/istio-certs/${CN}.key" --cert="/tmp/istio-certs/${CN}.crt"

  kubectl apply -f - <<EOF
apiVersion: networking.istio.io/v1beta1
kind: Gateway
metadata:
  name: api-gateway
  namespace: sample-istio
spec:
  selector:
    istio: ingressgateway # use Istio default gateway implementation
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - "api.${INTERNAL_DNS_SUFFIX}"
    - "http.${INTERNAL_DNS_SUFFIX}"
    tls:
      httpsRedirect: true # sends 301 redirect for http requests
  - port:
      number: 443
      name: https-httpbin
      protocol: HTTPS
    tls:
      mode: SIMPLE
      credentialName: http-credential
    hosts:
    - http.${INTERNAL_DNS_SUFFIX}
  - port:
      number: 443
      name: https-api
      protocol: HTTPS
    tls:
      mode: SIMPLE
      credentialName: api-credential
    hosts:
    - api.${INTERNAL_DNS_SUFFIX}
EOF
  kubectl apply -f - <<EOF
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: api-gateway-pathprefix
  namespace: sample-istio
spec:
  hosts:
  - "api.${INTERNAL_DNS_SUFFIX}"
  gateways:
  - sample-istio/api-gateway
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
        host: httpbin.sample-istio.svc.cluster.local
---
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: httpbin
  namespace: sample-istio
spec:
  hosts:
  - "http.${INTERNAL_DNS_SUFFIX}"
  gateways:
  - sample-istio/api-gateway
  - mesh # applies to all the sidecars in the mesh
  http:
  - route:
    - destination:
        port:
          number: 8000
        host: httpbin.sample-istio.svc.cluster.local
---
# Add timeout for internal service registry
# Notice lack of gateways - which means that it is applied only to sidecars in the mesh
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: httpbin-timeout
  namespace: sample-istio
spec:
  hosts:
  - httpbin.sample-istio.svc.cluster.local
  http:
  - timeout: 3s
    route:
    - destination:
        host: httpbin.sample-istio.svc.cluster.local
EOF
}

function exposeSampleAppExternally() {
  # TLS certificates has to be in namespace where ingressgateway is deployed (istio-system)
  CN="http.${EXTERNAL_DNS_SUFFIX}"

  kubectl apply -f - <<EOF
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: external-httpbin
  namespace: sample-istio
spec:
  hosts:
  - "http.${EXTERNAL_DNS_SUFFIX}"
  gateways:
  - istio-system/external-wildcard-gateway
  - mesh # applies to all the sidecars in the mesh
  http:
  - route:
    - destination:
        port:
          number: 8000
        host: httpbin.sample-istio.svc.cluster.local
EOF
}

# Main
deploySampleAppWithK8SIngress
exposeSampleAppViaInternalIstioNatively

if [ "${MODE}" = "gke" ]; then
  exposeSampleAppExternally
fi
