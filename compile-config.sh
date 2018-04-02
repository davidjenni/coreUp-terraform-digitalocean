#!/usr/bin/env bash
set -e

# parse JSON from stdin; this is the external datasource's 'query' dictionary:
eval "$(jq -r '@sh "_CONFIG_YAML=\(.config_yaml)"')"

_CONFIG=$(ct -in-file $_CONFIG_YAML)
# result needs to be a simple key/value JSON map
jq -n --arg config "$_CONFIG" '{"config":$config}'
