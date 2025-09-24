#!/usr/bin/env bash

set -e

project_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

./components/database/bin/sqitch-run.sh revert -y
./components/database/bin/sqitch-run.sh deploy --verify

sleep 1

hurl --very-verbose ./test.hurl

echo -e ""
