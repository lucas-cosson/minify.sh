#!/bin/dash

for DIR in $1/*; do
    if [ -d "$DIR" ]; then
        for FILE in "$DIR"; do
            echo "$(basename $FILE)"
        done
    fi
done