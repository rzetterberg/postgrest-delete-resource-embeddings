#!/usr/bin/env bash

project_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

session="pdre"

# Setup new session
#---------------------------------------------------------------------------------

mkdir -p "${project_dir}/tmp/"{db,api}

HOST="localhost"
BACKEND_PORT=8080
BASE_URL="http://${HOST}:${BACKEND_PORT}"

tmux new-session -d -s $session \
     -e "PDRE_BASE_URL=${BASE_URL}" \
     -e "PDRE_API_BASE_URL=${BASE_URL}/api" \
     -e "PDRE_API_HOST=${HOST}" \
     -e "PDRE_API_JWT_SECRET=secret_that_is_longer_than_32_characters" \
     -e "PDRE_API_PORT=8080" \
     -e "PDRE_API_WORK_DIR=${project_dir}/tmp/api" \
     -e "PDRE_DB_ADMIN_USER=postgres" \
     -e "PDRE_DB_ADMIN_PASSWORD=devpass" \
     -e "PDRE_DB_HOST=${HOST}" \
     -e "PDRE_DB_NAME=pdre" \
     -e "PDRE_DB_PORT=5432" \
     -e "PDRE_DB_AUTHENTICATOR_USER=authenticator" \
     -e "PDRE_DB_AUTHENTICATOR_PASSWORD=devpass" \
     -e "PDRE_DB_WORK_DIR=${project_dir}/tmp/database"

# PostgreREST and PostgreSQL window
#---------------------------------------------------------------------------------

tmux send-keys "nix develop" C-m
tmux send-keys "cd components/api" C-m
tmux send-keys "./bin/start.sh" C-m

tmux new-window
tmux select-window -t 2

tmux send-keys "nix develop" C-m
tmux send-keys "cd components/database" C-m
tmux send-keys "./bin/start.sh" C-m

# CLI window
#---------------------------------------------------------------------------------

tmux new-window
tmux select-window -t 3

tmux send-keys "nix develop" C-m
tmux send-keys "./components/database/bin/sqitch-run.sh deploy --verify" C-m

# Binds
#---------------------------------------------------------------------------------

tmux attach-session -t $session
