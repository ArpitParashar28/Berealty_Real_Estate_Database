#!/usr/bin/env bash
set -euo pipefail
mkdir -p outputs
args=(-u"${MYSQL_USER:-root}")
[[ -n "${MYSQL_HOST:-}" ]] && args+=("-h${MYSQL_HOST}")
[[ -n "${MYSQL_PORT:-}" ]] && args+=("-P${MYSQL_PORT}")
[[ -n "${MYSQL_PASSWORD:-}" ]] && export MYSQL_PWD="$MYSQL_PASSWORD"

mysql "${args[@]}" --table < sql/07_verification.sql | tee outputs/verification.txt
mysql "${args[@]}" --table < sql/04_queries.sql | tee outputs/q1_q14.txt
mysql "${args[@]}" --table < sql/05_safe_dml_demo.sql | tee outputs/q15_safe_dml.txt
mysql "${args[@]}" --table < sql/06_trigger_demo.sql | tee outputs/trigger_demo.txt
printf '\nEvidence written to outputs/.\n'
