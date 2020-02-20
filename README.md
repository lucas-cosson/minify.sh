# minify.sh
Minify CSS and HTML source code from the command line using dash, by **Lucas Cosson & Nathanaël Houn** 

Made as a shell project for L2-S4 "Système" 

## What can it do ?
This tool can reduce HTML and CSS from the command line, reproducing the whole tree view of a `source_folder` into an the `dest_folder` with the minified code.

```
Usage : ./minifier.sh [OPTION]... dir_source dir_dest

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
                tags (opening or closing) listed in the ’tags_file’ are deleted
```

## Tools used
We use `tr`, `sed` and `perl` to remove unecessary code (spaces, line breaks, comments) from the existing files and `du` to calculate disk usage.

## Possible improvement
- Reduce images