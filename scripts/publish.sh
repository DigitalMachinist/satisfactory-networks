#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
DEST_DIR="/mnt/c/Users/jrose/AppData/Local/FactoryGame/Saved/SaveGames/Computers"
TIMESTAMP=`date +%Y-%m-%d_%H-%M-%S`

# Copy current Satisfactory Ficsit-Networks computer configuration into the backup folder in case anything breaks.
echo "Backing up Satisfactory folder..."
cp -rf "$DEST_DIR" "$SCRIPT_DIR/../backup/$TIMESTAMP"

# Delete the existing computer configuration.
echo "Cleaning Satisfactory folder..."
#rm -rf "$DEST_DIR/*"

# Publish *this* computer configuration into the Satisfactory folder.
echo "Publishing computers to Satisfactory folder..."
#cp -rf "$SCRIPT_DIR/../computers/*" "$DEST_DIR"

echo "Done!"