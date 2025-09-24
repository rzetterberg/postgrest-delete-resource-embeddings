#!/usr/bin/env bash

set -euo pipefail

bin_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
component_dir=$(dirname "${bin_dir}")

target="--target=\"db:pg:///${PDRE_DB_NAME}?host=${PDRE_DB_HOST}&user=${PDRE_DB_ADMIN_USER}&password=${PDRE_DB_ADMIN_PASSWORD}\""

exec sqitch $@ --chdir "${component_dir}/sqitch" "${target}"
