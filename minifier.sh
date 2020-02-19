#!/bin/dash

# Var #########################################################################
DO_CSS=false
DO_HTML=false
VERBOSE=false
FORCE=false
NEXT_ARGUMENT_IS_TAG=false
TAG_FILE=""

# Functions ###################################################################

help () {
  echo 'Usage : ./minifier.sh [OPTION]... dir_source dir_dest

    Minifies HTML and/or CSS files with :
        dir_source path to the root directory of the website to be minified
        dir_dest path to the root directory of the minified website

    OPTIONS
    --help      show help and exit
    -v          displays the list of minified files; and for each
                file, its final and initial sizes, and its reduction
                percentage
    -f          if the dir_dest file exists, its content is
                removed without asking for confirmation of deletion
    --css       CSS files are minified
    --html      HTML files are minified
    if none of the 2 previous options is present, the HTML and CSS
    files are minified

    -t tags_file the "white space" characters preceding and following the
                tags (opening or closing) listed in the ’tags_file’ are deleted'
  exit 0                                      # exit without error
}

error () {
  echo "$1"
  echo 'Enter "./minifier.sh --help" for more information.'
  exit 1                                      # exit with error
}

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
    FILE_CONTENT=$(tr '\n' ' ' < "$1" | sed -r 's/<!--.{0,100}-->//g') # TODO : marche pour les commentaires de 100 max
    FILE_CONTENT=$(echo -n "$FILE_CONTENT" | sed -E -e 's/[[:space:]]+/ /g' ) # inutile sauf pour \v, echo fait le découpage avec l'IFS

    if $ENABLE_TAG; then
      for TAG in $(cat "$2"); do
        FILE_CONTENT=$(echo -n "$FILE_CONTENT" | sed -E -e "s/[[:space:]]*<$TAG([^>]*)>*>[[:space:]]/<$TAG\1>/gI" -e "s/[[:space:]]*<\/$TAG([^>]*)>[[:space:]]/<\/$TAG\1>/gI")
      done
    fi

    echo "$FILE_CONTENT"
}

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

# Parse arguments #############################################################

if [ $# -eq  0 ]; then
  error 'Paths to ’dir_source’ and ’dir_dest’ directories must be specified'
fi

for ARGUMENT in "$@"; do

  if ( $NEXT_ARGUMENT_IS_TAG ); then
    NEXT_ARGUMENT_IS_TAG=false
    if [ ! -f "$ARGUMENT" ]; then
      error 'Next argument of -t option need to be a file'
    fi
    continue                                # continue
  fi

  LONG_OPTION=${ARGUMENT#'--'}
  if [ "$LONG_OPTION" != $ARGUMENT ]; then
    case "$LONG_OPTION" in
      'help' )                              # help
        if [ "$#" -ne 1 ]; then 
          error 'Invalid option'
        fi
        help
        ;;

      'CSS'|'css' )                               # CSS
        if ( DO_CSS ); then
          error 'The argument --css is redundant'
        fi
        DO_CSS=true
        ;;

      'HTML'|'html' )                              # HTML
        if ( DO_HTML ); then
          error 'The argument --html is redundant'
        fi
        DO_HTML=true
        ;;
      * )
        error "The '$ARGUMENT' option is not supported Jube"
    esac
    continue                                # continue
  fi

  SHORT_OPTION=${ARGUMENT#'-'}
  if [ "$SHORT_OPTION" != $ARGUMENT ]; then
    case "$SHORT_OPTION" in
      't' )                                 # TAG
        if ( TAG ); then
          error 'The argument -t is redundant'
        fi
        TAG=true
        NEXT_ARGUMENT_IS_TAG=true
        ;;

      'v' )                                 # VERBOSE
        if ( VERBOSE ); then
          error 'The argument -v is redundant'
        fi
        VERBOSE=true
        ;;

      'f' )                                 # FORCE
        if ( FORCE ); then
          error 'The argument -f is redundant'
        fi
        FORCE=true
        ;;

      * )
        error "The '$ARGUMENT' option is not supported Dadeau"
    esac
    continue                                # continue
  fi

  if [ ! -n "$DIR_SOURCE" ]; then
    if [ ! -d "$ARGUMENT" ]; then
      error "$ARGUMENT is not a directory"
    fi
    DIR_SOURCE=$ARGUMENT
  elif [ ! -n "$DIR_DEST" ]; then
    DIR_DEST=$ARGUMENT
  else
    error "More than two pathes given"
  fi

done


# Check and set variables #####################################################
if [ ! -n "$DIR_SOURCE" ] || [ ! -n "$DIR_DEST" ]; then
  error 'Paths to ’dir_source’ and ’dir_dest’ directories must be specified'
fi

if [ "$DIR_SOURCE" = "$DIR_DEST" ]; then
  error 'DIR_SOURCE and DIR_DEST must be different'
fi

if ! $DO_CSS && ! $DO_HTML; then
  DO_CSS=true
  DO_HTML=true
fi 



# Temporary ###################################################################
echo "Test : this is all the variables :"
echo "DO_HTML : $DO_HTML"
echo "DO_CSS : $DO_CSS"
echo "VERBOSE : $VERBOSE"
echo "FORCE : $FORCE"
echo "DIR_SOURCE : $DIR_SOURCE"
echo "DIR_DEST : $DIR_DEST"

# Remove DIR_DEST -------------------------------------------------------------
if [ -e "$DIR_DEST" ]; then
  if $FORCE; then
    if [ -d "$DIR_DEST" ]; then
      rm -rf "$DIR_DEST"
    else
      rm -f "$DIR_DEST"
    fi
  else
    if [ -d "$DIR_DEST" ]; then
      read -p "Directory $DIR_DEST already exist. Do you want to delete it ? [Y/n] " ANSWER
      if [ "$ANSWER" = "Y" ] || [ "$ANSWER" = "y" ]; then
        rm -rf "$DIR_DEST"
      else
        echo "Quit script. "
        exit 0
      fi
    else
      read -p "File $DIR_DEST already exist. Do you want to delete it ? [Y/n] " ANSWER
      if [ "$ANSWER" = "Y" ] || [ "$ANSWER" = "y" ]; then
        rm -f "$DIR_DEST"
      else
        echo "Quit script. "
        exit 0
      fi
    fi
  fi
fi

mkdir $DIR_DEST

# Copy and minify files -------------------------------------------------------
for SOURCE_FILE in $(find "$DIR_SOURCE"); do
  DEST_FILE=$DIR_DEST${SOURCE_FILE#$DIR_SOURCE/}

  if [ -d "$SOURCE_FILE" ]; then
    mkdir "$DEST_FILE"
    if [ $? -ne 0 ]; then
      echo "Directory creation failed, end of program" >&2
      exit 2
    fi
    continue
  fi

  if [ $DO_CSS ] && [ "${SOURCE_FILE%.css}" = "$SOURCE_FILE" ]; then
    minify_css $SOURCE_FILE > $DEST_FILE
    continue
  fi

  if [ $DO_HTML ] && [ "${SOURCE_FILE%.html}" = "$SOURCE_FILE" ]; then
    minify_html $SOURCE_FILE $TAG_FILE > $DEST_FILE
    continue
  fi

  cp $SOURCE_FILE $DEST_FILE
done