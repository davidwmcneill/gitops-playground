SHELL := /bin/bash

create:
	CREATE_CLUSTER=true ./bootstrap.sh 

stop:
	k3d cluster stop playground

start:
	cp manifests/calico/calico.yaml /tmp/calico.yaml
	k3d cluster start playground

destroy:
	k3d cluster delete playground
