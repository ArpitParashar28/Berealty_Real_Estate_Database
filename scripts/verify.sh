#!/usr/bin/env bash
set -euo pipefail
args=(-u"${MYSQL_USER:-root}")
[[ -n "${MYSQL_HOST:-}" ]] && args+=("-h${MYSQL_HOST}")
[[ -n "${MYSQL_PORT:-}" ]] && args+=("-P${MYSQL_PORT}")
[[ -n "${MYSQL_PASSWORD:-}" ]] && export MYSQL_PWD="$MYSQL_PASSWORD"
mysql "${args[@]}" --table < sql/07_verification.sql
