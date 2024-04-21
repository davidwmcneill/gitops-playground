SHELL := /bin/bash
#xport LOCAL_DEV_PATH=/Users/dmc/git/k3dvolume

create:
	CREATE_CLUSTER=true ./bootstrap.sh 

stop:
	k3d cluster stop playground

start:
	mkdir -p /tmp/calico && cp manifests/calico/calico.yaml /tmp/calico
	k3d cluster start playground

destroy:
	k3d cluster delete playground
