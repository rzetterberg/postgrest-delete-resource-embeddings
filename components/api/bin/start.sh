#!/usr/bin/env bash

set -euo pipefail

#=================================================================================
# Step 0
#=================================================================================

mkdir -p "${PDRE_API_WORK_DIR}"

cd "${PDRE_API_WORK_DIR}"

DB_URI="postgres://${PDRE_DB_AUTHENTICATOR_USER}:$PDRE_DB_AUTHENTICATOR_PASSWORD@${PDRE_DB_HOST}:${PDRE_DB_PORT}/${PDRE_DB_NAME}";

cat <<EOF > ./postgrest.conf
db-uri = "${DB_URI}"
db-schema = "api"
db-anon-role = "anonymous"
db-pool = 100
db-pool-timeout = 10

server-host = "${PDRE_API_HOST}"
server-port = ${PDRE_API_PORT}

max-rows = 100

openapi-server-proxy-uri = "${PDRE_API_BASE_URL}"
jwt-secret = "${PDRE_API_JWT_SECRET}"

log-level = "info"
EOF

#=================================================================================
# Step 1
#=================================================================================

echo ">> Starting to listen for database connection: ${PDRE_DB_HOST}:${PDRE_DB_PORT}"

SLEEP_TIME=1

while ! nc -z "${PDRE_DB_HOST}" ${PDRE_DB_PORT};
do
  echo ">> Database is not accepting connections yet, will sleep for ${SLEEP_TIME}"
  sleep "${SLEEP_TIME}"
  SLEEP_TIME=$((SLEEP_TIME + 1))
done

sleep 1

echo ">> Starting postgREST"
exec postgrest ./postgrest.conf
