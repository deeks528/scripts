#!/bin/bash

set -e

if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <VARIABLE_NAME> [VARIABLE_NAME...] <ENV_FILE_PATH>"
    echo
    echo "Example:"
    echo "  $0 PORT HOST DATABASE_URL ./backend/.env"
    exit 1
fi

ENV_PATH="${!#}"

# Remove the last argument (file path)
VARIABLES=("${@:1:$#-1}")

mkdir -p "$(dirname "$ENV_PATH")"

> "$ENV_PATH"

for VAR in "${VARIABLES[@]}"; do
    read -rp "$VAR: " VALUE
    echo "$VAR=$VALUE" >> "$ENV_PATH"
done

echo
echo "✓ .env file created: $ENV_PATH"
