#!/bin/dash

minify_html () {    
    if [ "${1%.html}" = "$1" ]; then
        echo "DEV : this is not a .html file"
        exit 1
    fi

    local FILE_CONTENT
    FILE_CONTENT=$(tr '\n' ' ' < "$1");
    echo $FILE_CONTENT
}

minify_html $1