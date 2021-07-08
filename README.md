# Gitops-playground

----
A quick start K3d setup bundled with Argocd

----

## Why?
- An easy way to have Argocd up and running locally for testing new features/releases
- Gitops for home lab projects
- Minimal Prerequisites 

----
## Requirements

- docker
- kubectl
- curl/wget

----
## To start the cluster with bootstrapping
This will wrap the install script for k3d located here: [k3d install script](https://github.com/rancher/k3d#get)

**Note:** This will update kubeconfig context 

----
### What is in the bootsrap
The bootstrap makes a few changes from the default k3d installation:

- Replace Traefik v1 with Ingress-Nginx
- Replace the default network (Flannel) with Calico to support Network policies

----
### Run full bootstrap
```
CREATE_CLUSTER=true ./bootstrap.sh 
```

----
## Argocd
Argocd is installed as part of the cluster bootstrap using klipper-helm from inside the running cluster

----
### Argocd Login
The Argocd url is presented via ingress on the path /argocd: http://localhost:8080/argocd

Login details:
```
Username: admin
Password: letmein
```

----
## K3d Options

### View cluster
```
k3d cluster list
```
### Stop cluster
```
k3d cluster stop playground
```
### Start cluster
```
k3d cluster start playground
```

----
## Clean up

### remove the cluster

```
k3d cluster delete playground
```


