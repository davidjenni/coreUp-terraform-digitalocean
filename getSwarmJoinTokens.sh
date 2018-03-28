#!/usr/bin/env bash
# Credits to https://github.com/knpwrs/docker-swarm-terraform
set -e

# parse JSON from stdin; this is the external datasource's 'query' dictionary:
eval "$(jq -r '@sh "_MGR_HOST=\(.host) _USER=\(.user) _SSH_PRIV_KEY=\(.private_key)"')"

_MGR_TOKEN=$(ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i $_SSH_PRIV_KEY \
    $_USER@$_MGR_HOST docker swarm join-token manager -q)

_WRKR_TOKEN=$(ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i $_SSH_PRIV_KEY \
    $_USER@$_MGR_HOST docker swarm join-token worker -q)

# result needs to be JSON as well:
jq -n --arg manager "$_MGR_TOKEN" --arg worker "$_WRKR_TOKEN" '{"manager":$manager,"worker":$worker}'
