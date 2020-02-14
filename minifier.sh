#!/bin/dash

echo 'Hello world'

# Parse arguments
for ARGUMENT in "$@"; do
  
  OPTION=${ARGUMENT#'--'}
  if [ "$OPTION" = "help" ]; then
    help
  fi
done
