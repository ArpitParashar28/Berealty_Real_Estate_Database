#!/usr/bin/env bash
set -euo pipefail
MYSQL_ARGS=("${MYSQL_HOST:+-h${MYSQL_HOST}}" "${MYSQL_PORT:+-P${MYSQL_PORT}}" -u"${MYSQL_USER:-root}")
# Remove empty host/port args.
clean=(); for x in "${MYSQL_ARGS[@]}"; do [[ -n "$x" ]] && clean+=("$x"); done
if [[ -n "${MYSQL_PASSWORD:-}" ]]; then export MYSQL_PWD="$MYSQL_PASSWORD"; fi
mysql "${clean[@]}" < sql/01_schema.sql
mysql "${clean[@]}" < sql/02_triggers.sql
mysql "${clean[@]}" < sql/03_sample_data.sql
printf 'Berealty database built successfully.\n'
