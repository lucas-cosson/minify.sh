#!/bin/dash

minify_css(){
    if [ "${1%.css}" = "$1" ]; then
        echo "DEV : this is not a .css file"
        exit 1
    fi

    local FILE_CONTENT
    FILE_CONTENT=$(cat $1 | sed "s#/\*.*\*/\(.\+\)#\1#" | sed -E "/\/\*/,/\*\// d")             #Permet de suprimer les commentaire 1)sur une ligne 2)multiligne
    FILE_CONTENT=$(echo -n $FILE_CONTENT | sed -E "s/([[:alnum:]])[ ]*([{;:,>+])[ ]*/\1\2/g")   #Permet de supprimer les espaces entre les différents label
    echo $FILE_CONTENT
}

minify_css $1
