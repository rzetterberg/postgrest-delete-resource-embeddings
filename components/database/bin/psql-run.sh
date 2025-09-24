#!/usr/bin/env bash

set -euo pipefail

export PGPASSWORD="${PDRE_DB_ADMIN_PASSWORD}"

exec psql -h "${PDRE_DB_HOST}" -U "${PDRE_DB_ADMIN_USER}" "${PDRE_DB_NAME}" "$@"
