#!/bin/bash

set -e

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <ENV_EXAMPLE> <ENV_FILE>"
    echo
    echo "Example:"
    echo "  $0 .env.example .env"
    exit 1
fi

ENV_EXAMPLE="$1"
ENV_PATH="$2"

if [ ! -f "$ENV_EXAMPLE" ]; then
    echo "Error: File not found: $ENV_EXAMPLE"
    exit 1
fi

mkdir -p "$(dirname "$ENV_PATH")"

> "$ENV_PATH"

while IFS= read -r LINE || [ -n "$LINE" ]; do

    # Preserve comments and empty lines
    if [[ -z "$LINE" || "$LINE" =~ ^[[:space:]]*# ]]; then
        echo "$LINE" >> "$ENV_PATH"
        continue
    fi

    # Process environment variable lines
    if [[ "$LINE" =~ ^[[:space:]]*([A-Za-z_][A-Za-z0-9_]*)=(.*)$ ]]; then
        VAR="${BASH_REMATCH[1]}"
        DEFAULT="${BASH_REMATCH[2]}"

        echo
        echo "$VAR"

        if [ "$DEFAULT" = "secret" ]; then
            read -rsp "$VAR: " VALUE </dev/tty
            echo
        else
            if [ -n "$DEFAULT" ]; then
                echo "(example: $DEFAULT)"
            fi

            read -rp "$VAR: " VALUE </dev/tty
        fi

        # If nothing was entered, preserve the default
        if [ -z "$VALUE" ]; then
            VALUE="$DEFAULT"
        fi

        # Never write the "secret" marker itself
        if [ "$VALUE" = "secret" ]; then
            VALUE=""
        fi

        echo "$VAR=$VALUE" >> "$ENV_PATH"
    else
        echo "$LINE" >> "$ENV_PATH"
    fi

done < "$ENV_EXAMPLE"

echo
echo "✓ .env file created: $ENV_PATH"
