#!/usr/bin/env bash
# usage for gke deployment: ./sample-http-server.sh gke shared1-dev
# usage for gke deployment with istio with xlb ingress: ./sample-http-server.sh gke-istio-xlb shared1-dev
# usage for minikube deployment: ./sample-http-server.sh minikube

case $1 in
gke)
  MODE=gke
  CLUSTER_NAME="${2:?CLUSTER_NAME is required}"
  INTERNAL_DNS_SUFFIX="internal.gke.$(echo -n "${CLUSTER_NAME}" | sed 's/-/./g').gcp.testing"
  API_GTW_DNS_SUFFIX="gxlb.gke.$(echo -n "${CLUSTER_NAME}" | sed 's/-/./g').gcp.testing"
  ;;
gke-istio-xlb)
  MODE=gke-istio-xlb
  CLUSTER_NAME="${2:?CLUSTER_NAME is required}"
  INTERNAL_DNS_SUFFIX="internal.gke.$(echo -n "${CLUSTER_NAME}" | sed 's/-/./g').gcp.testing"
  EXTERNAL_DNS_SUFFIX="external.gke.$(echo -n "${CLUSTER_NAME}" | sed 's/-/./g').gcp.testing"
  ;;
minikube)
  MODE=minikube
  INTERNAL_DNS_SUFFIX="internal.minikube"
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

  mkdir -p /tmp/istio-certs
  CN="httpbin.${INTERNAL_DNS_SUFFIX}"
  openssl req -x509 -sha256 -subj "/CN=${CN}" -days 365 -out "/tmp/istio-certs/${CN}.crt" -newkey rsa:2048 -nodes -keyout "/tmp/istio-certs/${CN}.key"
  kubectl create -n istio-ingress secret tls httpbin-credential --key="/tmp/istio-certs/${CN}.key" --cert="/tmp/istio-certs/${CN}.crt"

  # sidecar is not necessary when only Ingress is used from istio
  kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
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
          service:
            name: httpbin
            port:
              number: 8000
        path: /
        pathType: Prefix
  # Istio support Ingresses with TLS but secret has to be in istio-ingress namespace
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
  # TLS certificates has to be in namespace where ingressgateway is deployed (istio-ingress)
  CN="api.${INTERNAL_DNS_SUFFIX}"
  openssl req -x509 -sha256 -subj "/CN=${CN}" -days 365 -out "/tmp/istio-certs/${CN}.crt" -newkey rsa:2048 -nodes -keyout "/tmp/istio-certs/${CN}.key"
  kubectl create -n istio-ingress secret tls api-credential --key="/tmp/istio-certs/${CN}.key" --cert="/tmp/istio-certs/${CN}.crt"
  CN="http.${INTERNAL_DNS_SUFFIX}"
  openssl req -x509 -sha256 -subj "/CN=${CN}" -days 365 -out "/tmp/istio-certs/${CN}.crt" -newkey rsa:2048 -nodes -keyout "/tmp/istio-certs/${CN}.key"
  kubectl create -n istio-ingress secret tls http-credential --key="/tmp/istio-certs/${CN}.key" --cert="/tmp/istio-certs/${CN}.crt"

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
  # TLS certificates has to be in namespace where ingressgateway is deployed (istio-ingress)
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
  - istio-ingress/external-wildcard-gateway
  - mesh # applies to all the sidecars in the mesh
  http:
  - route:
    - destination:
        port:
          number: 8000
        host: httpbin.sample-istio.svc.cluster.local
EOF
}

function exposeSampleAppExternallyViaAPIGateway() {
  kubectl apply -f - <<EOF
apiVersion: gateway.networking.k8s.io/v1beta1
kind: HTTPRoute
metadata:
  name: httpbin
  namespace: sample-istio
spec:
  hostnames:
  - "http.${API_GTW_DNS_SUFFIX}"
  parentRefs:
  - group: gateway.networking.k8s.io
    kind: Gateway
    name: external
    namespace: gateways
  rules:
  - backendRefs:
    - group: ""
      kind: Service
      name: httpbin
      namespace: sample-istio
      port: 8000
EOF
}

# Main
deploySampleAppWithK8SIngress
exposeSampleAppViaInternalIstioNatively

if [ "${MODE}" = "gke" ]; then
  exposeSampleAppExternallyViaAPIGateway
fi

if [ "${MODE}" = "gke-istio-xlb" ]; then
  exposeSampleAppExternally
fi
