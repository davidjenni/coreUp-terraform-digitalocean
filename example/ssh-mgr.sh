#!/usr/bin/env bash

# assumes outputs from testCluster.tf:
ssh core@$(terraform output manager) -i $(terraform output sshKeyFile) $*
