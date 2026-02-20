#!/bin/bash

# Build LaTeX templates to PDF.
# The engine is read from the first line of each .tex file:
#     % !TEX program = <engine>
#
# Engines that produce DVI (uplatex, platex, uptex, platex-dev)
# are automatically followed by dvipdfmx.
#
# Usage:
#     ./__build.sh              # build all *.tex in this directory
#     ./__build.sh foo.tex      # build a single template

DVI_ENGINES="uplatex platex uptex platex-dev"

is_dvi_engine() {
    local engine="$1"
    for e in $DVI_ENGINES; do
        [ "$e" = "$engine" ] && return 0
    done
    return 1
}

build() {
    local template="${1%.tex}"

    if [ ! -f "${template}.tex" ]; then
        echo "Error: '${template}.tex' not found"
        return 1
    fi

    # Read engine from first line: % !TEX program = <engine>
    local first_line
    first_line=$(head -1 "${template}.tex")
    local engine
    engine=$(echo "$first_line" | sed -n 's/^%[[:space:]]*!TEX[[:space:]]*program[[:space:]]*=[[:space:]]*\([^[:space:]]*\).*/\1/p')

    if [ -z "$engine" ]; then
        echo "Error: no '% !TEX program = ...' directive found in '${template}.tex'"
        return 1
    fi

    echo "==> Building '${template}.tex' with $engine ..."

    # Run engine twice for cross-references, TOC, etc.
    "$engine" -interaction=nonstopmode -halt-on-error "${template}.tex" || return 1
    "$engine" -interaction=nonstopmode -halt-on-error "${template}.tex" || return 1

    # DVI engines need an extra dvipdfmx pass
    if is_dvi_engine "$engine"; then
        dvipdfmx "${template}.dvi" || return 1
    fi

    echo "==> Done: ${template}.pdf"
}

if [ -z "$1" ]; then
    failed=()
    for tex_file in *.tex; do
        build "$tex_file" || failed+=("$tex_file")
    done
    if [ ${#failed[@]} -gt 0 ]; then
        echo ""
        echo "The following templates failed to build:"
        for f in "${failed[@]}"; do
            echo "    $f"
        done
        exit 1
    fi
else
    build "$1"
fi
