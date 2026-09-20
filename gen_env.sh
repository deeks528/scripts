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

DESCRIPTION=""

while IFS= read -r LINE || [ -n "$LINE" ]; do

    # Preserve blank lines
    if [[ -z "$LINE" ]]; then
        echo >> "$ENV_PATH"
        continue
    fi

    # Store comments as descriptions
    if [[ "$LINE" =~ ^[[:space:]]*#(.*)$ ]]; then
        DESCRIPTION="${BASH_REMATCH[1]}"
        DESCRIPTION="${DESCRIPTION#"${DESCRIPTION%%[![:space:]]*}"}"
        echo "$LINE" >> "$ENV_PATH"
        continue
    fi

    # Process environment variables
    if [[ "$LINE" =~ ^[[:space:]]*([A-Za-z_][A-Za-z0-9_]*)=(.*)$ ]]; then
        VAR="${BASH_REMATCH[1]}"
        DEFAULT="${BASH_REMATCH[2]}"

        # Display description
        if [ -n "$DESCRIPTION" ]; then
            echo "$DESCRIPTION"
        fi

        # Display example if a value exists
        if [ -n "$DEFAULT" ]; then
            echo "(example: $DEFAULT)"
        fi

        read -rp "$VAR: " VALUE </dev/tty

        echo "$VAR=$VALUE" >> "$ENV_PATH"

        DESCRIPTION=""
    else
        echo "$LINE" >> "$ENV_PATH"
    fi

done < "$ENV_EXAMPLE"

echo
echo "✓ .env file created: $ENV_PATH"
