#!/bin/bash

compile() {
    local template="${1%.tex}"

    if [ ! -f "${template}.tex" ]; then
        echo "Error: File '${template}.tex' not found"
        return 1
    fi

    latexpand --keep-comments "${template}.tex" > "__latexpand/${template}.tex" && \
    echo -e "\n% TEMPLATE COMPILED:\n%     $(date +%Y-%m-%dT%H:%M:%S%z)" >> "__latexpand/${template}.tex"
}

if [ -z "$1" ]; then
    for tex_file in *.tex; do
        compile "$tex_file"
    done
else
    compile "$1"
fi
