SHELL := /bin/bash

startup:
	CREATE_CLUSTER=true ./bootstrap.sh 

destroy:
	k3d cluster delete playground