#!/bin/bash

set -e

# Colors
CYAN='\033[0;36m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
RESET='\033[0m'

if [ "$#" -ne 2 ]; then
    echo -e "${RED}Usage:${RESET} $0 <ENV_EXAMPLE> <ENV_FILE>"
    echo
    echo "Example:"
    echo "  $0 .env.example .env"
    exit 1
fi

ENV_EXAMPLE="$1"
ENV_PATH="$2"

if [ ! -f "$ENV_EXAMPLE" ]; then
    echo -e "${RED}Error:${RESET} File not found: $ENV_EXAMPLE"
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

        # Description
        if [ -n "$DESCRIPTION" ]; then
            echo -e "${CYAN}${DESCRIPTION}${RESET}"
        fi

        # Example
        if [ -n "$DEFAULT" ]; then
            echo -e "${YELLOW}(example: ${DEFAULT})${RESET}"
        fi

        # Input
        read -erp "$(echo -e "${GREEN}${VAR}${RESET}: ")" VALUE </dev/tty

        echo "$VAR=$VALUE" >> "$ENV_PATH"

        # Empty line after every input
        echo

        DESCRIPTION=""
    else
        echo "$LINE" >> "$ENV_PATH"
    fi

done < "$ENV_EXAMPLE"

echo -e "${GREEN}✓ .env file created: ${ENV_PATH}${RESET}"
