# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Is

A collection of LaTeX templates for mathematical documents. Templates are named `{lang}_{doctype}_math.tex` (e.g., `en_article_math.tex`, `ja_book_math.tex`). Supported languages: `en`, `fr`, `ja`, `ko`. Document types: `article`, `book`, `beamer`, `note`, `poster`.

## Build Commands

Build a single template to PDF:
```bash
./__batch_build.sh en_article_math.tex
```

Build all templates:
```bash
./__batch_build.sh
```

Flatten a template's `\input` directives into `__latexpand/` (for arXiv):
```bash
./__compile.sh en_article_math.tex   # single file
./__compile.sh                        # all files
```

Manual build (engine is declared on line 1 of each `.tex` file as `% !TEX program = <engine>`):
- **xelatex** (English/French): `xelatex file.tex` (twice for cross-refs)
- **uplatex** (Japanese/CJK): `uplatex file.tex && dvipdfmx file.dvi` (run uplatex twice before dvipdfmx)
- With bibliography: run engine → `biber file` → engine twice → dvipdfmx (if DVI engine)

## Architecture

All shared components live in `__common/`. The top-level `.tex` files are thin shells that `\input` from `__common/` and contain minimal document-specific content.

### `__common/` Layout

| Directory | Purpose |
|-----------|---------|
| `guide/` | Commented build-command recipes per engine (`xelatex.tex`, `uplatex.tex`, `platex.tex`, `pdflatex.tex`) — included first in every template |
| `packages/` | Package groups: `general.tex`, `math.tex`, `fonts.tex`, `ref.tex`, `graphic.tex`, `enumitem.tex`, `japanese.tex`, `korean.tex`, `ref_fr.tex`, `enumitem_ko.tex` |
| `commands/` | Custom macros: `math.tex` (operators, categories, number theory), `color.tex`, `boxes.tex`, `sorry.tex`, `ordinal.tex`, `ordinal_fr.tex` |
| `term/` | Language-specific terminology macros: `en.tex`, `fr.tex`, `ja.tex`, `ko.tex` |
| `theorem/` | Theorem-like environment definitions: `latin.tex` (for Latin-script docs), `cjk.tex` (for CJK docs), `beamer.tex` |
| `cref/` | Cleveref configuration: `latin.tex`, `cjk.tex` |
| `placeholder/` | Stub content for abstract, body, references, bibliography, and Beamer/poster slides |
| `tcolorbox/` | tcolorbox configurations for poster layouts |

### Terminology System

Instead of hardcoding strings like "Theorem" or "定理", all templates use `\term*` macros (e.g., `\termTheorem`, `\termDefinition`, `\termIntroduction`). These are defined per-language in `__common/term/{lang}.tex`. Theorem environments reference these macros directly, so swapping the `\input{__common/term/...}` line changes the display language of all environment names at once.

### Engine Selection by Language

- English/French templates: `xelatex` → PDF directly
- Japanese templates: `uplatex` → DVI → `dvipdfmx`
- Korean templates: `xelatex` → PDF directly
- `__batch_build.sh` reads the `% !TEX program = <engine>` directive from line 1 and automatically adds the `dvipdfmx` step for DVI engines (`uplatex`, `platex`, `uptex`, `platex-dev`)

### Adding a New Template

1. Copy the closest existing template (same language/doctype)
2. Set `% !TEX program = <engine>` on line 1
3. `\input` the appropriate `__common/term/{lang}.tex` and `__common/theorem/{latin|cjk}.tex`
4. For CJK: add the language package (`pxbabel` for Japanese, etc.) and `__common/packages/{japanese|korean}.tex`
