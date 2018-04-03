#!/usr/bin/env bash
set -e

# parse JSON from stdin; this is the external datasource's 'query' dictionary:
eval "$(jq -r '@sh "_CONFIG_YAML=\(.config_yaml) _TLS_DIR=\(.tls_dir)"')"

_CONFIG=$(ct -in-file $_CONFIG_YAML -files-dir $_TLS_DIR)
# result needs to be a simple key/value JSON map
jq -n --arg config "$_CONFIG" '{"config":$config}'
