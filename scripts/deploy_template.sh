#!/bin/bash

FILE_EEPROM="eeprom.lua"
UUID_REPLACE="__DRIVE_UUID_PRIMARY__"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

PWD=$( pwd )
DIR_SCRIPT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

if [ -z "$1" ]; then
    echo "Argument 'template' is required!"
    echo "Usage: ./deploy_template.sh <template>";
    exit 1
fi

DIR_TEMPLATE="$DIR_SCRIPT/../templates/$1"
cd "$DIR_TEMPLATE"
ALIASES="$( find . -mindepth 1 -maxdepth 1 -type d | cut -c3- )"
for ALIAS in $ALIASES
do
    printf "Discovered template ${GREEN}$1/$ALIAS${NC}!\n"
done

# Copy the templ
DIR_DRIVES="$DIR_SCRIPT/../drives"
cd "$DIR_DRIVES"
for ALIAS in $ALIASES
do
    printf "Deploying ${GREEN}$1/$ALIAS${NC} template:\n"

    DRIVES="$( find . -mindepth 1 -maxdepth 1 -type d -exec test -f '{}'/tags/$1 -a -f '{}'/tags/$ALIAS \; -print | sort -u | cut -c3-34 )"
    for DRIVE in $DRIVES
    do
        printf "Updating drive ${RED}$DRIVE${NC} from template ${GREEN}$1/$ALIAS${NC}...\n"
        DIR_DEST="$DIR_DRIVES/$DRIVE"
        echo $DIR_DEST
        find . -name \* -delete # rm -rf wasn't working here but this does the job.
        cp -rf "$DIR_TEMPLATE/$ALIAS" "$DIR_DEST"

        # If this is a primary drive and eeprom.lua exists, rewrite {DRIVE_UUID_PRIMARY} to the drive's UUID.
        if [ $ALIAS = "primary" ]; then
            if [ -f "$DIR_DEST/$FILE_EEPROM" ]; then
                sed -i s/$UUID_REPLACE/$DRIVE/ "$DIR_DEST/$FILE_EEPROM"
                echo "Primary drive UUID set!"
            fi
        fi
    done
done

# Return to the directory the user started from.
cd $PWD