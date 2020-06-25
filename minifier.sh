#!/bin/dash

# Var #########################################################################
DO_CSS=false
DO_HTML=false
VERBOSE=false
FORCE=false
TAG=false
NEXT_ARGUMENT_IS_TAG=false
TAG_FILE=""

# Functions ###################################################################

# Print the script usage
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
                tags (opening or closing) listed in the "tags_file" are deleted'
  exit 0                                      # exit without error
}

# Output the error described in $1 and exit the program
error () {
  echo "$1"
  echo 'Enter "./minifier.sh --help" for more information.'
  exit 1                                      # exit with error
}

# Print the Disk usage difference between two files
# $1 file type
# $2 Bigger file
# $3 Smaller file
print_du_diff () {
  local INITIAL_SIZE
  local FINAL_SIZE
  INITIAL_SIZE=$(du "$2" -b | cut -f1)
  FINAL_SIZE=$(du "$3" -b | cut -f1)
  echo "File $1 : $2 --> $FINAL_SIZE / $INITIAL_SIZE : $((100 - 100 * FINAL_SIZE / INITIAL_SIZE))%"
}

# Minify an html file and send it to the standard output
# $1 : path to an .html file
# $2 : optional, path to tags_file (delete spaces around all html tags in the tags_file)
minify_html () {
  local ENABLE_TAG
  ENABLE_TAG=false
  if [ -n "$2" ]; then
    ENABLE_TAG=true
  fi

  local FILE_CONTENT
  FILE_CONTENT=$(tr '\n' ' ' < "$1" | sed -E -e 's/[[:space:]]+/ /g')       # delete extra spaces
  FILE_CONTENT=$(printf '%s' "$FILE_CONTENT" | perl -pe 's/<!--.*?-->//g')  # delete html comments

  if $ENABLE_TAG; then
    for TAG in $(cat "$2"); do
      FILE_CONTENT=$(printf '%s' "$FILE_CONTENT" | sed -E -e "s/[[:space:]]*<$TAG([^>]*)>*>[[:space:]]/<$TAG\1>/gI" -e "s/[[:space:]]*<\/$TAG([^>]*)>[[:space:]]/<\/$TAG\1>/gI")
    done
  fi

  printf '%s' "$FILE_CONTENT"
  return
}

# Minify an css file and send it to the standard output
# $1 : path to an .css file
minify_css(){
  local FILE_CONTENT

  FILE_CONTENT="$(tr '\n' ' ' < "$1" | perl -pe 's|/\*.*?\*/||g')"                                        # delete css comments
  FILE_CONTENT=$(printf '%s' "$FILE_CONTENT" | sed -r -e 's/[[:space:]]*([{};:,>+])[[:space:]]*/\1/g')  # delete spaces between labels
  
  printf '%s' "$FILE_CONTENT"                       # we use printf instead of echo because echo transform the html escaped char codes
  return
}

# Parse arguments #############################################################

if [ $# -eq  0 ]; then
  error 'Paths to "dir_source" and "dir_dest" directories must be specified'
fi

for ARGUMENT in "$@"; do

  if ( $NEXT_ARGUMENT_IS_TAG ); then
    NEXT_ARGUMENT_IS_TAG=false
    if [ ! -f "$ARGUMENT" ]; then
      error 'Next argument of -t option need to be a file'
    fi
    TAG_FILE=$ARGUMENT
    continue                                # continue
  fi

  LONG_OPTION=${ARGUMENT#'--'}
  if [ "$LONG_OPTION" != "$ARGUMENT" ]; then
    case "$LONG_OPTION" in
      'help' )                                      # help
        if [ "$#" -ne 1 ]; then 
          error 'Invalid option'
        fi
        help
        ;;

      'CSS'|'css' )                                 # CSS
        if ( $DO_CSS ); then
          error 'The argument --css is redundant'
        fi
        DO_CSS=true
        ;;

      'HTML'|'html' )                               # HTML
        if ( $DO_HTML ); then
          error 'The argument --html is redundant'
        fi
        DO_HTML=true
        ;;
      * )
        error "The '$ARGUMENT' option is not supported"
    esac
    continue                                # continue
  fi

  SHORT_OPTION=${ARGUMENT#'-'}
  if [ "$SHORT_OPTION" != "$ARGUMENT" ]; then
    case "$SHORT_OPTION" in
      't' )                                         # TAG
        if ( $TAG ); then
          error 'The argument -t is redundant'
        fi
        TAG=true
        NEXT_ARGUMENT_IS_TAG=true
        ;;

      'v' )                                         # VERBOSE
        if ( $VERBOSE ); then
          error 'The argument -v is redundant'
        fi
        VERBOSE=true
        ;;

      'f' )                                         # FORCE
        if ( $FORCE ); then
          error 'The argument -f is redundant'
        fi
        FORCE=true
        ;;

      * )
        error "The '$ARGUMENT' option is not supported"
    esac
    continue                                # continue
  fi

  if [ -z "$DIR_SOURCE" ]; then
    if [ ! -d "$ARGUMENT" ]; then
      error "$ARGUMENT is not a directory"
    fi
    DIR_SOURCE=$ARGUMENT
  elif [ -z "$DIR_DEST" ]; then
    DIR_DEST=$ARGUMENT
  else
    error "More than two pathes given"
  fi

done


# Check and set variables #####################################################
if [ -z "$DIR_SOURCE" ] || [ -z "$DIR_DEST" ]; then
  error 'Paths to "dir_source" and "dir_dest" directories must be specified'
fi

if [ "$DIR_SOURCE" = "$DIR_DEST" ]; then
  error 'DIR_SOURCE and DIR_DEST must be different'
fi

if ! ( $DO_CSS ) && ! ( $DO_HTML ); then
  DO_CSS=true
  DO_HTML=true
fi

if [ "${DIR_DEST%/}" = "$DIR_DEST" ]; then       # add '/' at the end of the path
  DIR_DEST=$DIR_DEST/
fi

if [ "${SOURCE_DEST%/}" = "$SOURCE_DEST" ]; then # add '/' at the end of the path
  SOURCE_DEST=$SOURCE_DEST/
fi

# Remove DIR_DEST if it exist -------------------------------------------------
if [ -e "$DIR_DEST" ]; then
  if $FORCE; then
    if [ -d "$DIR_DEST" ]; then
      rm -rf "$DIR_DEST"
    else
      rm -f "$DIR_DEST"
    fi
  else
    if [ -d "$DIR_DEST" ]; then
      read -rp "Directory $DIR_DEST already exist. Do you want to delete it ? [Y/n] " ANSWER
      if [ "$ANSWER" = "Y" ] || [ "$ANSWER" = "y" ]; then
        rm -rf "$DIR_DEST"
      else
        echo "Quit script. "
        exit 0
      fi
    else
      read -rp "File $DIR_DEST already exist. Do you want to delete it ? [Y/n] " ANSWER
      if [ "$ANSWER" = "Y" ] || [ "$ANSWER" = "y" ]; then
        rm -f "$DIR_DEST"
      else
        echo "Quit script. "
        exit 0
      fi
    fi
  fi
fi

# Copy and minify files -------------------------------------------------------
for SOURCE_FILE in $(find "$DIR_SOURCE"); do
  DEST_FILE=$DIR_DEST${SOURCE_FILE#$DIR_SOURCE}

  if [ -d "$SOURCE_FILE" ]; then
    if ! mkdir "$DEST_FILE"; then
      echo "Directory '$DEST_FILE' creation failed, end of program" >&2
      exit 2
    fi
    continue
  fi

  if ( "$DO_CSS" ) && ! [ "${SOURCE_FILE%.css}" = "$SOURCE_FILE" ]; then
    minify_css "$SOURCE_FILE" > "$DEST_FILE"
    if ( $VERBOSE ); then
      print_du_diff "CSS " "$SOURCE_FILE" "$DEST_FILE"
    fi
    continue
  fi

  if ( $DO_HTML ) && ! [ "${SOURCE_FILE%.html}" = "$SOURCE_FILE" ]; then
    minify_html "$SOURCE_FILE" "$TAG_FILE" > "$DEST_FILE"
    if ( $VERBOSE ); then
      print_du_diff "HTML" "$SOURCE_FILE" "$DEST_FILE"
    fi
    continue
  fi

  cp "$SOURCE_FILE" "$DEST_FILE"
done

TOTAL_SIZE_SOURCE=$(du "$DIR_SOURCE" -b -s | cut -f1)
TOTAL_SIZE_DEST=$(du "$DIR_DEST" -b -s | cut -f1)
if ( $VERBOSE ); then
  echo "Finished. Total size saved : $(($((TOTAL_SIZE_SOURCE - TOTAL_SIZE_DEST))/1000))Kb ($((100 - 100 * TOTAL_SIZE_DEST / TOTAL_SIZE_SOURCE))%)"
fi

exit 0
