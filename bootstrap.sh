#!/usr/bin/env bash
echo $BASH_VERSION

: ${CREATE_CLUSTER:="false"}

verifySupported() {
  if ! type "curl" > /dev/null && ! type "wget" > /dev/null; then
    echo "Either curl or wget is required"
    exit 1
  fi
  if ! type "kubectl" > /dev/null; then
    echo "kubectl is required"
    exit 1
  fi
}


installK3d() {
  if type "curl" > /dev/null; then
    curl -s https://raw.githubusercontent.com/rancher/k3d/main/install.sh | TAG=v4.0.0 bash
  elif type "wget" > /dev/null; then
    wget -q -O - https://raw.githubusercontent.com/rancher/k3d/main/install.sh | TAG=v4.0.0 bash
  fi
}

createCluster() {
  if [ $CREATE_CLUSTER = "true" ]; then
    k3d cluster create --config k3d-config.yml 
  fi
}

waitForReady() {
  local namespace=$1
  local deployment=$2
  until kubectl -n $namespace wait --for=condition=available --timeout=120s $deployment &> /dev/null;
  do
      echo "Waiting for $deployment ..."
      sleep 1
  done
  echo "$deployment running."
}

createArgocd(){
  kubectl create namespace argocd
  kubectl create serviceaccount helm-argocd -n argocd
  kubectl apply -f ./manifests
  kubectl replace --force -f ./manifests/job/argocd-job.yaml
}

createArgocdResources(){
  kubectl apply -f ./manifests/argocd-resources
}

verifySupported
installK3d
createCluster
waitForReady kube-system deployment/traefik
createArgocd
waitForReady argocd deployment/argo-argocd-server
createArgocdResources