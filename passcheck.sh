#!/usr/bin/env bash
#
# passcheck — Local k-Anonymity password checker with breach counts
#
# Usage:
#   ./passcheck build <wordlist.txt>
#   ./passcheck check <password>
#   ./passcheck check -f passwords.txt
#   ./passcheck check        (interactive mode)
#

set -euo pipefail

DB_DIR="passcheck_db"
BUCKET_DIR="$DB_DIR/buckets"

############################################
usage() {
    echo "Usage:"
    echo "  $0 build <wordlist.txt>"
    echo "  $0 check <password>"
    echo "  $0 check -f <passwords.txt>"
    echo "  $0 check"
    exit 1
}

############################################
color_red()   { echo -e "\033[31m$1\033[0m"; }
color_green() { echo -e "\033[32m$1\033[0m"; }
color_yellow(){ echo -e "\033[33m$1\033[0m"; }

############################################
build_db() {
    WORDLIST="$1"

    [[ ! -f "$WORDLIST" ]] && { echo "Wordlist not found."; exit 1; }

    mkdir -p "$BUCKET_DIR"
    TMP_HASHES="$DB_DIR/all_hashes.tmp"

    echo "[*] Hashing passwords..."
    while IFS= read -r line; do
        [[ -z "$line" ]] && continue
        printf "%s" "$line" | sha1sum | awk '{print toupper($1)}'
    done < "$WORDLIST" > "$TMP_HASHES"

    echo "[*] Counting duplicates and building buckets..."
    sort "$TMP_HASHES" | uniq -c | while read -r count hash; do
        prefix=${hash:0:5}
        suffix=${hash:5}
        echo "${suffix}:${count}" >> "$BUCKET_DIR/$prefix.txt"
    done

    rm "$TMP_HASHES"

    echo "[*] Sorting buckets..."
    for f in "$BUCKET_DIR"/*.txt; do
        LC_ALL=C sort -u "$f" -o "$f"
    done

    echo "[✓] Database built successfully."
}

############################################
check_one() {
    local pass="$1"

    full_hash=$(printf "%s" "$pass" | sha1sum | awk '{print toupper($1)}')
    prefix=${full_hash:0:5}
    suffix=${full_hash:5}
    bucket_file="$BUCKET_DIR/$prefix.txt"

    if [[ ! -f "$bucket_file" ]]; then
        color_green "NOT FOUND"
        return
    fi

    result=$(grep -F "^$suffix:" "$bucket_file" || true)

    if [[ -n "$result" ]]; then
        count=${result#*:}

        if (( count > 100000 )); then
            color_red "CRITICAL — Seen $count times"
        elif (( count > 1000 )); then
            color_red "HIGH RISK — Seen $count times"
        elif (( count > 10 )); then
            color_yellow "MEDIUM RISK — Seen $count times"
        else
            color_yellow "LOW RISK — Seen $count times"
        fi
    else
        color_green "NOT FOUND"
    fi
}

############################################
check_mode() {

    [[ ! -d "$BUCKET_DIR" ]] && {
        echo "Database not found. Run: $0 build <wordlist.txt>"
        exit 1
    }

    # Case 1: Single password argument
    if [[ $# -eq 1 ]]; then
        check_one "$1"
        exit 0
    fi

    # Case 2: File mode
    if [[ $# -eq 2 && "$1" == "-f" ]]; then
        FILE="$2"
        [[ ! -f "$FILE" ]] && { echo "File not found."; exit 1; }

        while IFS= read -r pass; do
            [[ -z "$pass" ]] && continue
            echo -n "Checking: $pass → "
            check_one "$pass"
        done < "$FILE"

        exit 0
    fi

    # Case 3: Interactive
    echo "Enter passwords to check (Ctrl-D to exit):"
    while IFS= read -r pass; do
        [[ -z "$pass" ]] && continue
        check_one "$pass"
    done
}

############################################
# MAIN
############################################

[[ $# -lt 1 ]] && usage

case "$1" in
    build)
        [[ $# -ne 2 ]] && usage
        build_db "$2"
        ;;
    check)
        shift
        check_mode "$@"
        ;;
    *)
        usage
        ;;
esac
