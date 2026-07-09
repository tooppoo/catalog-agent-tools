#!/usr/bin/env bash

set -u

usage() {
  cat <<'EOF'
Usage:
  test-bare-markdown-paths.sh [-0] [-n] [file...]

Validate Markdown files for bare file paths in prose.

Input:
  - file arguments, or
  - file paths from standard input, one path per line

Options:
  -0  Read NUL-delimited file paths from standard input.
  -n  Print matching line details as file:line:path.
      Without -n, print each matching Markdown file once.
  -h  Show this help.

Detects bare repository-style file paths in Markdown prose, such as:

  docs/example.md
  ./docs/example.md
  ../docs/example.md
  src/main.rs

The script ignores:

  - fenced code blocks
  - inline code spans
  - Markdown inline links, such as [README](../README.md)
  - Markdown image links, such as ![diagram](docs/diagram.svg)
  - reference-style link definitions, such as [README]: ../README.md
  - non-Markdown files

This is a heuristic validator, not a full Markdown parser.
EOF
}

nul_input=0
show_lines=0

while getopts '0nh' opt; do
  case "$opt" in
    0)
      nul_input=1
      ;;
    n)
      show_lines=1
      ;;
    h)
      usage
      exit 0
      ;;
    *)
      usage >&2
      exit 2
      ;;
  esac
done

shift "$((OPTIND - 1))"

files=()

if [ "$#" -gt 0 ]; then
  files=("$@")
else
  if [ -t 0 ]; then
    usage >&2
    exit 2
  fi

  if [ "$nul_input" -eq 1 ]; then
    while IFS= read -r -d '' file; do
      files+=("$file")
    done
  else
    while IFS= read -r file; do
      [ -n "$file" ] || continue
      files+=("$file")
    done
  fi
fi

status=0

for file in "${files[@]}"; do
  case "$file" in
    *.md|*.markdown)
      ;;
    *)
      continue
      ;;
  esac

  if [ ! -f "$file" ]; then
    printf 'error: not a file: %s\n' "$file" >&2
    status=1
    continue
  fi

  awk -v show_lines="$show_lines" -v display_file="$file" '
BEGIN {
  path_re = "^(\\./|\\.\\./|[[:alnum:]_.-]+/)[[:alnum:]_.@%+-]+(/[[:alnum:]_.@%+-]+)*\\.(md|markdown|adoc|rst|txt|json|toml|ya?ml|kdl|rs|go|sh|ts|tsx|js|jsx|css|scss|html|svg|png|jpg|jpeg|gif|webp|pdf)$"
}

FNR == 1 {
  in_fence = 0
  fence_char = ""
  reported = 0
  file_status = 0
}

function is_fence_opener(s) {
  return s ~ /^[[:space:]]*(```+|~~~+)/
}

function is_fence_closer(s) {
  if (fence_char == "`") {
    return s ~ /^[[:space:]]*```+[[:space:]]*$/
  }

  if (fence_char == "~") {
    return s ~ /^[[:space:]]*~~~+[[:space:]]*$/
  }

  return 0
}

function enter_fence(s) {
  if (s ~ /^[[:space:]]*```+/) {
    fence_char = "`"
    in_fence = 1
    return
  }

  if (s ~ /^[[:space:]]*~~~+/) {
    fence_char = "~"
    in_fence = 1
    return
  }
}

function strip_inline_code(s, before, after) {
  while (match(s, /`[^`]*`/)) {
    before = substr(s, 1, RSTART - 1)
    after = substr(s, RSTART + RLENGTH)
    s = before " " after
  }

  return s
}

function strip_markdown_inline_links(s, before, after) {
  # Remove ordinary inline Markdown links and images:
  #   [README](../README.md)
  #   ![diagram](docs/diagram.svg)
  #
  # The whole link is removed so linked paths are not reported as bare paths.
  while (match(s, /!?\[[^][]*\]\([^)]*\)/)) {
    before = substr(s, 1, RSTART - 1)
    after = substr(s, RSTART + RLENGTH)
    s = before " " after
  }

  return s
}

function strip_reference_link_definition(s) {
  # Remove reference-style link definitions:
  #   [README]: ../README.md
  #   [README]: ../README.md "README"
  if (s ~ /^[[:space:]]*\[[^]]+\]:[[:space:]]+/) {
    return ""
  }

  return s
}

function trim_candidate(s) {
  gsub(/^[<({\["]+/, "", s)
  gsub(/[>)}\]".,;:!?]+$/, "", s)
  return s
}

function report_match(path) {
  if (show_lines == "1") {
    printf "%s:%d:%s\n", display_file, FNR, path
  } else if (!reported) {
    print display_file
    reported = 1
  }

  file_status = 1
}

function scan_line(line, fields, n, i, candidate) {
  line = strip_inline_code(line)
  line = strip_markdown_inline_links(line)
  line = strip_reference_link_definition(line)

  n = split(line, fields, /[[:space:]]+/)

  for (i = 1; i <= n; i++) {
    candidate = trim_candidate(fields[i])

    if (candidate ~ path_re) {
      report_match(candidate)

      if (show_lines != "1") {
        return
      }
    }
  }
}

in_fence && is_fence_closer($0) {
  in_fence = 0
  fence_char = ""
  next
}

in_fence {
  next
}

is_fence_opener($0) {
  enter_fence($0)
  next
}

{
  scan_line($0)
}

END {
  if (file_status) {
    exit 1
  }
}
' "$file" || status=1
done

exit "$status"
