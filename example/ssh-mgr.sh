#!/usr/bin/env bash

# assumes outputs from testCluster.tf:
ssh $(terraform output sshUser)@$(terraform output manager) -p $(terraform output sshPort) -i $(terraform output sshKeyFile) $*
