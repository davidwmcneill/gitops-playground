SHELL := /bin/bash

startup:
	CREATE_CLUSTER=true ./bootstrap.sh 

stop:
	k3d cluster stop playground

start:
	k3d cluster start playground

destroy:
	k3d cluster delete playground
