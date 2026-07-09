#!/usr/bin/env bash

set -u

usage() {
  cat <<'EOF'
Usage:
  check-markdown-semantic-line-breaks.sh [-0] [file...]

Validate Markdown files for likely hard-wrapped prose.

Input:
  - file arguments, or
  - file paths from standard input, one path per line

Options:
  -0  Read NUL-delimited file paths from standard input.
  -h  Show this help.

A prose line break is considered allowed when the previous prose line ends with one of:

  . , : ;

The script ignores:

  - fenced code blocks
  - blank lines
  - headings
  - tables
  - horizontal rules
  - HTML comments
  - non-Markdown files

This is a heuristic validator, not a full Markdown parser.
EOF
}

nul_input=0

while getopts '0h' opt; do
  case "$opt" in
    0)
      nul_input=1
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

  awk -v display_file="$file" '
FNR == 1 {
  in_fence = 0
  fence_char = ""
  prev_line = ""
  prev_lineno = 0
  prev_is_prose = 0
  file_status = 0
}

function trim(s) {
  sub(/^[[:space:]]+/, "", s)
  sub(/[[:space:]]+$/, "", s)
  return s
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

function is_horizontal_rule(s) {
  return s ~ /^[[:space:]]*(-[[:space:]]*){3,}$/ || \
         s ~ /^[[:space:]]*(\*[[:space:]]*){3,}$/ || \
         s ~ /^[[:space:]]*(_[[:space:]]*){3,}$/
}

function is_structural_markdown_line(s) {
  s = trim(s)

  if (s == "") {
    return 1
  }

  if (s ~ /^#/) {
    return 1
  }

  if (s ~ /^<!--/) {
    return 1
  }

  if (s ~ /^\|/) {
    return 1
  }

  if (is_horizontal_rule(s)) {
    return 1
  }

  return 0
}

function is_new_list_item(s) {
  s = trim(s)

  return s ~ /^([-+*])[[:space:]]+/ || \
         s ~ /^[0-9]+[.)][[:space:]]+/
}

function is_prose_line(s) {
  s = trim(s)

  if (is_structural_markdown_line(s)) {
    return 0
  }

  return 1
}

function ends_with_allowed_break(s) {
  s = trim(s)

  return s ~ /[.,:;]$/
}

function report_hard_wrap(previous, current) {
  printf "%s:%d: possible hard-wrapped prose\n", display_file, prev_lineno
  printf "  previous: %s\n", previous
  printf "  next:     %s\n", current
  file_status = 1
}

in_fence && is_fence_closer($0) {
  in_fence = 0
  fence_char = ""
  prev_is_prose = 0
  next
}

in_fence {
  next
}

is_fence_opener($0) {
  enter_fence($0)
  prev_is_prose = 0
  next
}

{
  current = $0
  current_is_prose = is_prose_line(current)

  if (current_is_prose && is_new_list_item(current)) {
    prev_line = current
    prev_lineno = FNR
    prev_is_prose = 1
    next
  }

  if (prev_is_prose && current_is_prose && !ends_with_allowed_break(prev_line)) {
    report_hard_wrap(prev_line, current)
  }

  if (current_is_prose) {
    prev_line = current
    prev_lineno = FNR
    prev_is_prose = 1
  } else {
    prev_line = ""
    prev_lineno = 0
    prev_is_prose = 0
  }
}

END {
  if (file_status) {
    exit 1
  }
}
' "$file" || status=1
done

exit "$status"
