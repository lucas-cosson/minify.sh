#!/bin/dash

# Functions --------------------------------------------------------------------

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
  exit 0
}

error () {
  echo "$1"
  echo 'Enter "./minifier.sh --help" for more information.'
  exit 1;
}

# Parse arguments --------------------------------------------------------------
for ARGUMENT in "$@"; do

  OPTION=${ARGUMENT#'--'}
  case "$OPTION" in
    'help' )
      help
      ;;

    * )
      error "The '$ARGUMENT' option is not supported"
done

