#!/usr/bin/env bash
set -e

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

## check if docker is running
checkDocker(){
  {
    docker ps -q
  } || {
    echo "Docker is not running. Please start docker on your computer"
    echo "When docker has finished starting up press [ENTER} to continue"
    read
  }
}

## copy calico manifest to tmp as an absolute path is required
calicoManifest(){
  mkdir -p /tmp/calico && cp manifests/calico/calico.yaml /tmp/calico
}

installK3d() {
  if type "curl" > /dev/null; then
    curl -s https://raw.githubusercontent.com/rancher/k3d/main/install.sh | TAG=v5.6.3 bash
  elif type "wget" > /dev/null; then
    wget -q -O - https://raw.githubusercontent.com/rancher/k3d/main/install.sh | TAG=v5.6.3 bash
  fi
}

createCluster() {
  if [ $CREATE_CLUSTER = "true" ]; then
    k3d cluster create --config k3d-config.yml --volume "$LOCAL_DEV_PATH:/tmp/k3dvolume"
  fi
}

waitForReadyDeployment() {
  local namespace=$1
  local deployment=$2
  until kubectl -n $namespace wait --for=condition=available --timeout=120s $deployment &> /dev/null;
  do
      echo "Waiting for $deployment ..."
      sleep 1
  done
  echo "$deployment running."
}

waitForReadyRollout() {
  local namespace=$1
  local daemonset=$2
  until kubectl rollout status -n $namespace $daemonset &> /dev/null;
  do
      echo "Waiting for $daemonset ..."
      sleep 1
  done
  echo "$daemonset running."
}


createArgocd(){
  kubectl create namespace argocd
  kubectl create serviceaccount helm-argocd -n argocd
  kubectl apply -f ./manifests/argocd
  kubectl replace --force -f ./manifests/job/argocd-job.yaml
}

createArgocdResources(){
  kubectl apply -f ./manifests/argocd-resources
}

startupComplete(){
    echo "Almost ready..."
    sleep 20 #Just allow time for the ingress to fully come online
    echo "Complete!"
    open http://localhost:8080/argocd
    echo "Username: admin / Password: letmein"
}

verifySupported
checkDocker
calicoManifest
installK3d
createCluster
createArgocd
waitForReadyDeployment argocd deployment/argo-argocd-server
createArgocdResources
waitForReadyRollout ingress daemonsets/svclb-ingress-nginx-controller
startupComplete