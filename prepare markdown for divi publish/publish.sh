#!/bin/bash

# publish.sh
# Converts an Obsidian markdown file to a Divi-ready HTML body file.
# Runs pandoc to convert the markdown to HTML, then strips the body
# content and collapses line wrapping so it pastes cleanly into Divi.
#
# Usage:
#   Convert a specific file:              ./publish.sh file.md
#   Force overwrite of existing output:   ./publish.sh -overwrite file.md

# Check for the -overwrite flag
overwrite=false
args=()
for arg in "$@"; do
    if [ "$arg" = "-overwrite" ]; then
        overwrite=true
    else
        args+=("$arg")
    fi
done

# Check a file argument was provided
if [ ${#args[@]} -eq 0 ]; then
    echo "Usage: publish.sh [-overwrite] file.md"
    exit 1
fi

file="${args[0]}"

# Check the source file exists
if [ ! -f "$file" ]; then
    echo "File not found: $file"
    exit 1
fi

# Check the file is a markdown file
if [[ "$file" != *.md ]]; then
    echo "Error: expected a .md file"
    exit 1
fi

# Build the output filename
base="${file%.md}"
output="${base}_BODY_ONLY.html"

# Skip if the output file already exists and -overwrite was not set
if [ -f "$output" ] && [ "$overwrite" = false ]; then
    echo "Skipping: $output (already exists, use -overwrite to replace)"
    exit 0
fi

# Convert markdown to HTML with pandoc, extract the body content,
# remove the <body> and </body> tags, strip carriage returns and collapse line wrapping
pandoc "$file" \
    | awk 'BEGIN{IGNORECASE=1} /<body/{found=1} found{print} /<\/body>/{found=0}' \
    | sed 's/<body[^>]*>//i' \
    | sed 's/<\/body>//i' \
    | tr -d '\r' \
    | tr '\n' ' ' \
    | sed 's/  */ /g' \
    > "$output"

if [ "$overwrite" = true ]; then
    echo "Overwritten: $output"
else
    echo "Created: $output"
fi
