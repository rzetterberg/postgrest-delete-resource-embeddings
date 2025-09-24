#!/usr/bin/env bash

set -euo pipefail

#=================================================================================
# Step 0
#=================================================================================

mkdir -p "${PDRE_DB_WORK_DIR}"/{pgdata,lock}

cd "${PDRE_DB_WORK_DIR}"

lock_dir=$(realpath ./lock)

cat <<EOF > ./pg_hba.conf
local all all     trust
host  all all all md5
EOF

cat <<EOF > ./postgresql.conf
hba_file = './pg_hba.conf'
log_destination = 'stderr'
listen_addresses = '${PDRE_DB_HOST}'
port = 5432
unix_socket_directories = '${lock_dir}'
log_statement = 'all'
log_min_messages = NOTICE
log_timezone = 'Europe/Stockholm'
timezone = 'Europe/Stockholm'
EOF

cat <<EOF > ./initial.sql
CREATE DATABASE ${PDRE_DB_NAME};

CREATE ROLE ${PDRE_DB_AUTHENTICATOR_USER} LOGIN NOINHERIT NOCREATEDB NOCREATEROLE NOSUPERUSER;
EOF

#=================================================================================
# Step 1
#=================================================================================

if ! test -e ./pgdata/PG_VERSION; then
  echo ">> Step 1: Initializing database"

  mkdir -m 0700 -p ./pgdata
  rm -f ./pgdata/*.conf

  initdb -U "${PDRE_DB_ADMIN_USER}" -D ./pgdata -E=UTF8
  touch "./pgdata/.run_initial_script"

  echo "-- Database initialized"
else
  echo ">> Database already initialized, skipping step"
fi

#=================================================================================
# Step 2
#=================================================================================

cp ./*.conf ./pgdata/
pg_ctl -D ./pgdata \
       -o "-c listen_addresses=\"\" -c unix_socket_directories=\"${lock_dir}\"" \
       -w start

function finish {
    pg_ctl -D ./pgdata -m fast -w stop
}

trap finish EXIT

psql_local="psql -v ON_ERROR_STOP=1 -h ${lock_dir} --username=${PDRE_DB_ADMIN_USER}"

if test -e "./pgdata/.run_initial_script"; then
  echo ">> Step 2: Running initial SQL"

  ${psql_local} -f ./initial.sql

  rm -f "./pgdata/.run_initial_script"

  echo "-- Step 2: Initial SQL complete"
else
  echo ">> Step 2: Initial script already run, skipping step"
fi

#=================================================================================
# Step 3
#=================================================================================

echo ">> Step 3: Setting admin password and JWT secret"

cat <<EOF | ${psql_local}
ALTER USER ${PDRE_DB_ADMIN_USER}
 WITH LOGIN ENCRYPTED PASSWORD '${PDRE_DB_ADMIN_PASSWORD}';

ALTER USER ${PDRE_DB_AUTHENTICATOR_USER}
 WITH LOGIN ENCRYPTED PASSWORD '${PDRE_DB_AUTHENTICATOR_PASSWORD}';

ALTER DATABASE ${PDRE_DB_NAME}
  SET "app.jwt_secret" TO '${PDRE_API_JWT_SECRET}';
EOF

#=================================================================================
# Step 4
#=================================================================================

echo ">> Step 4: Stopping database locally"
trap - EXIT
pg_ctl -D ./pgdata -m fast -w stop
echo "-- Step 4: Database stopped"

#=================================================================================
# Starting components
#=================================================================================

echo ">> Starting postgres"

exec postgres -D "$(realpath ./pgdata)"
