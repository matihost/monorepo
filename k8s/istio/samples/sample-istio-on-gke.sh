#!/usr/bin/env bash

function deploySampleAppWithK8SIngress() {
  kubectl create ns sample-istio
  # to enforce autosidecar injection in namespace
  # we do use Istion only as k8s Ingress controller
  # so it is not necessary
  # kubectl label namespace sample-istio istio-injection=enabled

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
  name: gce:podsecuritypolicy:privileged
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: Group
  name: system:serviceaccounts:sample-istio
EOF

  mkdir -p /tmp/istio-certs
  CN="httpbin.internal.gke.shared.dev"
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
  - host: httpbin.internal.gke.shared.dev
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
    - httpbin.internal.gke.shared.dev
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
  - name: http
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
  CN="api.internal.gke.shared.dev"
  openssl req -x509 -sha256 -subj "/CN=${CN}" -days 365 -out "/tmp/istio-certs/${CN}.crt" -newkey rsa:2048 -nodes -keyout "/tmp/istio-certs/${CN}.key"
  kubectl create -n istio-system secret tls api-credential --key="/tmp/istio-certs/${CN}.key" --cert="/tmp/istio-certs/${CN}.crt"
  CN="http.internal.gke.shared.dev"
  openssl req -x509 -sha256 -subj "/CN=${CN}" -days 365 -out "/tmp/istio-certs/${CN}.crt" -newkey rsa:2048 -nodes -keyout "/tmp/istio-certs/${CN}.key"
  kubectl create -n istio-system secret tls http-credential --key="/tmp/istio-certs/${CN}.key" --cert="/tmp/istio-certs/${CN}.crt"

  echo "Wait for istio to come up..." && sleep 60

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
    - "api.internal.gke.shared.dev"
    - "http.internal.gke.shared.dev"
  - port:
      number: 443
      name: httphttps
      protocol: HTTPS
    tls:
      mode: SIMPLE
      credentialName: http-credential
    hosts:
    - http.internal.gke.shared.dev
  - port:
      number: 443
      name: apihttps
      protocol: HTTPS
    tls:
      mode: SIMPLE
      credentialName: api-credential
    hosts:
    - api.internal.gke.shared.dev
EOF
  kubectl apply -f - <<EOF
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: api-gateway-pathprefix
  namespace: sample-istio
spec:
  hosts:
  - "api.internal.gke.shared.dev"
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
  - "http.internal.gke.shared.dev"
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
  - timeout: 5s
    route:
    - destination:
        host: httpbin.sample-istio.svc.cluster.local
EOF
}

function exposeSampleAppExternally() {
  # TLS certificates has to be in namespace where ingressgateway is deployed (istio-system)
  CN="http.external.gke.shared.dev"
  openssl req -x509 -sha256 -subj "/CN=${CN}" -days 365 -out "/tmp/istio-certs/${CN}.crt" -newkey rsa:2048 -nodes -keyout "/tmp/istio-certs/${CN}.key"
  kubectl create -n istio-system secret tls http-external-credential --key="/tmp/istio-certs/${CN}.key" --cert="/tmp/istio-certs/${CN}.crt"

  kubectl apply -f - <<EOF
apiVersion: networking.istio.io/v1beta1
kind: Gateway
metadata:
  name: external-gateway
  namespace: sample-istio
spec:
  selector:
    istio: external-ingressgateway # use Istio external ingress gateway implementation
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - "http.external.gke.shared.dev"
  - port:
      number: 443
      name: httphttps
      protocol: HTTPS
    tls:
      mode: SIMPLE
      credentialName: http-external-credential
    hosts:
    - http.external.gke.shared.dev
EOF
  kubectl apply -f - <<EOF
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: external-httpbin
  namespace: sample-istio
spec:
  hosts:
  - "http.external.gke.shared.dev"
  gateways:
  - sample-istio/external-gateway
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
exposeSampleAppExternally
