#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: $0 [template name]"
    exit 1
fi

# Remove .tex extension if present
template="${1%.tex}"

latexpand --keep-comments "${template}.tex" > "__latexpand/${template}.tex" && \
echo -e "\n% COMPILED:\n%     $(date +%Y-%m-%dT%H:%M:%S%z)" >> "__latexpand/${template}.tex"