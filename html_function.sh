#!/bin/dash

# $1 : path to an .html file
# $2 : optional, path to tags_file
# output the minified text to the standart output
minify_html () {
    if [ "${1%.html}" = "$1" ]; then
      echo "DEV : this is not a .html file" >&2
      exit 1
    fi

    local ENABLE_TAG
    ENABLE_TAG=false
    if [ -n "$2" ]; then
      if [ ! -f "$2" ]; then
        echo "DEV : tag_file is not a file" >&2
        exit 1
      fi
      ENABLE_TAG=true
    fi

    local FILE_CONTENT
    FILE_CONTENT=$(tr '\n' ' ' < "$1");
    FILE_CONTENT=$(echo -n "$FILE_CONTENT" | sed -E 's/<!--[^-]*-->//g') # TODO : marche pour tous sauf les commentaires qui contiennent des tirets
    FILE_CONTENT=$(echo -n "$FILE_CONTENT" | sed -E 's/[[:space:]]+/ /g' ) # inutile sauf pour \v, echo fait le découpage avec l'IFS

    if $ENABLE_TAG; then
      for TAG in $(cat "$2"); do
        FILE_CONTENT=$(echo -n "$FILE_CONTENT" | sed -E "s/[[:space:]]*<$TAG>*>[[:space:]]/<$TAG>/gI")
        FILE_CONTENT=$(echo -n "$FILE_CONTENT" | sed -E "s/[[:space:]]*<\/$TAG>[[:space:]]/<\/$TAG>/gI")
      done
    fi
    
    echo "$FILE_CONTENT"
}

minify_html $1 $2