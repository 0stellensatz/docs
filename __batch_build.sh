#!/bin/bash

# Build LaTeX templates to PDF.
# The engine is read from the first line of each .tex file:
#     % !TEX program = <engine>
#
# Engines that produce DVI (uplatex, platex, uptex, platex-dev)
# are automatically followed by dvipdfmx.
#
# Usage:
#     ./__batch_build.sh                     # build all *.tex in this directory
#     ./__batch_build.sh foo.tex             # build a single template
#     ./__batch_build.sh --biber             # build all, with biber bibliography pass
#     ./__batch_build.sh --biber foo.tex     # build single file with biber
#
# --biber / --biblatex:
#     Runs: engine → biber → engine → engine (→ dvipdfmx for DVI engines)

DVI_ENGINES="uplatex platex uptex platex-dev"

USE_BIBER=0

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

    if [ "$USE_BIBER" -eq 1 ]; then
        echo "==> Building '${template}.tex' with $engine + biber ..."
        # First pass: generate .bcf
        "$engine" -interaction=nonstopmode -halt-on-error "${template}.tex" || return 1
        # Biber pass: process bibliography
        biber "${template}" || return 1
        # Two more engine passes to resolve all references
        "$engine" -interaction=nonstopmode -halt-on-error "${template}.tex" || return 1
        "$engine" -interaction=nonstopmode -halt-on-error "${template}.tex" || return 1
    else
        echo "==> Building '${template}.tex' with $engine ..."
        # Run engine twice for cross-references, TOC, etc.
        "$engine" -interaction=nonstopmode -halt-on-error "${template}.tex" || return 1
        "$engine" -interaction=nonstopmode -halt-on-error "${template}.tex" || return 1
    fi

    # DVI engines need an extra dvipdfmx pass
    if is_dvi_engine "$engine"; then
        dvipdfmx "${template}.dvi" || return 1
    fi

    echo "==> Done: ${template}.pdf"
}

# Parse flags
for arg in "$@"; do
    case "$arg" in
        --biber|--biblatex) USE_BIBER=1 ;;
    esac
done

# Collect non-flag arguments
args=()
for arg in "$@"; do
    case "$arg" in
        --*) ;;
        *) args+=("$arg") ;;
    esac
done

if [ ${#args[@]} -eq 0 ]; then
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
    build "${args[0]}"
fi
