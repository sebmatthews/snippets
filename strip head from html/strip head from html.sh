#!/bin/bash

# strip_body.sh
# Extracts the <body>...</body> content from HTML files and saves each
# result as a new file with _BODY_ONLY appended to the filename.
#
# Usage:
#   Process specific files:   ./strip_body.sh file1.html file2.html
#   Process all .html files in current directory:   ./strip_body.sh

# If no arguments given, find all .html files in the current directory
if [ $# -eq 0 ]; then
    files=(*.html)
else
    files=("$@")
fi

# Check that at least one file was found
if [ ${#files[@]} -eq 0 ] || [ ! -f "${files[0]}" ]; then
    echo "No HTML files found."
    exit 1
fi

for file in "${files[@]}"; do

    # Skip if file does not exist
    if [ ! -f "$file" ]; then
        echo "Skipping: $file (not found)"
        continue
    fi

    # Build the output filename, inserting _BODY_ONLY before the extension
    # e.g. report.html becomes report_BODY_ONLY.html
    base="${file%.html}"
    output="${base}_BODY_ONLY.html"

    # Extract everything from the opening <body tag to the closing </body> tag.
    # The /<body/i pattern is case-insensitive and handles attributes on the body tag.
    awk 'BEGIN{IGNORECASE=1} /<body/{found=1} found{print} /<\/body>/{found=0}' "$file" > "$output"

    echo "Created: $output"

done
