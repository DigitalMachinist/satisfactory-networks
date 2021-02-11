#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

read -p "Are you sure? " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]
then
    # Delete the existing computer configuration.
    echo "Cleaning backup folder..."
    rm -rf "$SCRIPT_DIR/../backup/*"
fi
