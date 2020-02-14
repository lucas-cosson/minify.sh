#!/bin/dash

minify_css(){
    if [ "${1%.css}" = "$1" ]; then
        echo "DEV : this is not a .css file"
        exit 1
    fi

    local FILE_CONTENT
    FILE_CONTENT=$(grep -E [A-Za-z]\>) < $1
    FILE_CONTENT=$(tr '\n' ' ' < "$1" | sed -E "s/([[:alnum:]])[ ]*([{;:,>+])[ ]*/\1\2/g" source_test/styles/gazette.css);
    echo $FILE_CONTENT
}

minify_css $1
