#!/bin/dash

# Var -------------------------------------------------------------------------
DO_CSS=false
DO_HTML=false
VERBOSE=false
FORCE=false
NEXT_ARGUMENT_IS_TAG=false

# Functions -------------------------------------------------------------------

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

# Parse arguments -------------------------------------------------------------

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

      'CSS' )                               # CSS
        DO_CSS=true
        ;;

      'HTML' )                              # HTML
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
        TAG=true
        NEXT_ARGUMENT_IS_TAG=true
        ;;

      'v' )                                 # VERBOSE
        VERBOSE=true
        ;;

      'f' )                                 # FORCE
        FORCE=true
        ;;

      * )
        error "The '$ARGUMENT' option is not supported Dadeau"
    esac
    continue                                # continue
  fi

  if [ ! -d "$ARGUMENT" ]; then
    error "$ARGUMENT is not a directory"
  fi

  if [ ! -n "$DIR_SOURCE" ]; then
    DIR_SOURCE=$ARGUMENT
  elif [ ! -n "$DIR_DEST" ]; then
    DIR_DEST=$ARGUMENT
  else
    error "More than two pathes given"
  fi

done


# Check and set variables -----------------------------------------------------

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



# Temporary -------------------------------------------------------------------
echo "Test : this is all the variables :"
echo "DO_HTML : $DO_HTML"
echo "DO_CSS : $DO_CSS"
echo "VERBOSE : $VERBOSE"
echo "FORCE : $FORCE"
echo "DIR_SOURCE : $DIR_SOURCE"
echo "DIR_DEST : $DIR_DEST"
