#!/usr/bin/env bash
# usage for gke deployment: ./sample-grpc-server.sh gke shared1-dev
# usage for minikube deployment: ./sample-grpc-server.sh minikube

case $1 in
gke)
  CLUSTER_NAME="${2:?CLUSTER_NAME is required}"
  INTERNAL_DNS_SUFFIX="internal.gke.$(echo -n "${CLUSTER_NAME}" | sed 's/-/./g').gcp.testing"
  ;;
minikube)
  INTERNAL_DNS_SUFFIX="internal.testing.minikube"
  ;;
*)
  echo "Mode minikube or gke only supported"
  exit 1
  ;;
esac

function deploySampleApp() {
  kubectl create ns sample-istio || echo "ignoring..."
  # to enforce autosidecar injection in namespace
  # we do use Istion only as k8s Ingress controller
  # so it is not necessary
  kubectl label namespace sample-istio istio-injection=enabled --overwrite

  kubectl apply -n sample-istio -f - <<EOF
---
apiVersion: v1
kind: Service
metadata:
  name: grpc-server
spec:
  ports:
  - name: grpc-serverapp
    port: 8080
    targetPort: 8080
    protocol: TCP
  selector:
    app: grpc-server
  type: ClusterIP
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: grpc-server
spec:
  replicas: 1
  selector:
    matchLabels:
      app: grpc-server
  template:
    metadata:
      labels:
        app: grpc-server
    spec:
      containers:
      - args:
        - --address=:8080
        image: quay.io/matihost/grpc-server:latest
        imagePullPolicy: Always
        livenessProbe:
          exec:
            command:
            - ./grpc-health-probe
            - -addr=:8080
          initialDelaySeconds: 2
        name: grpc-server
        ports:
        - containerPort: 8080
        readinessProbe:
          exec:
            command:
            - ./grpc-health-probe
            - -addr=:8080
          initialDelaySeconds: 2
---
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: grpc-server
spec:
  gateways:
  - istio-ingress/internal-wildcard-gateway
  - mesh
  hosts:
  - "grpc.sample-istio.${INTERNAL_DNS_SUFFIX}"
  http:
  - route:
    - destination:
        host: grpc-server.sample-istio.svc.cluster.local
        port:
          number: 8080
EOF
}

# Main
deploySampleApp

echo -e "Test app via: \ngrpc-health-probe -tls -tls-no-verify -addr grpc.sample-istio.${INTERNAL_DNS_SUFFIX}:443\nor via go/grcp-client app:"
echo -e "grpc-client -tls -tls-no-verify -addr grpc.sample-istio.internal.testing.minikube:443 test"
