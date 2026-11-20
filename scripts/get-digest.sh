#!/usr/bin/env bash
# Read-only bridge: extract MAIA digest (Gate 1) or full abstracts by maia_id (Gate 2)
set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: $0 YYYY-MM-DD | --ids ID1,ID2,..." >&2
  exit 1
fi

if [ "$1" = "--ids" ]; then
  IDS="${2:?Missing comma-separated maia_id list}"
  if ! [[ "$IDS" =~ ^[0-9]+(,[0-9]+)*$ ]]; then
    echo "Error: --ids must be comma-separated integers" >&2
    exit 1
  fi
  IFS=',' read -ra ID_ARR <<< "$IDS"
  for id in "${ID_ARR[@]}"; do
    docker exec maia-db psql -U "${POSTGRES_USER:-maia_user}" -d "${POSTGRES_DB:-maia_memory}" -t -A -c "
      SELECT
        '### maia_id: ' || m.id || E'\n' ||
        '- **tags:** ' || coalesce((m.meta->'groq'->'tags')::text, '[]') || E'\n' ||
        '- **raw:**' || E'\n' || m.raw_text || E'\n\n---'
      FROM incoming_messages m
      WHERE m.id = $id;
    "
  done
else
  DATE="$1"
  if ! [[ "$DATE" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
    echo "Error: date must be YYYY-MM-DD" >&2
    exit 1
  fi
  docker exec maia-db psql -U "${POSTGRES_USER:-maia_user}" -d "${POSTGRES_DB:-maia_memory}" -t -A -F $'\t' -c "
    SELECT
      row_number() OVER (ORDER BY (d.payload->>'score')::int DESC, d.article_id),
      d.article_id,
      (d.payload->>'score')::int,
      d.kind,
      coalesce(m.source, '-'),
      d.payload->>'title',
      d.payload->>'url',
      replace(coalesce(m.meta->'groq'->>'reason', '-'), E'\n', ' ')
    FROM digest_log d
    JOIN incoming_messages m ON m.id = d.article_id
    WHERE d.d = '$DATE'
    ORDER BY 3 DESC, d.article_id;
  " | awk -F'\t' 'BEGIN {
    print "| # | maia_id | score | kind | cat | title | url | maia_reason |"
    print "|---|---|---|---|---|---|---|---|"
  } {
    printf "| %s | %s | %s | %s | %s | %s | %s | %s |\n", $1, $2, $3, $4, $5, $6, $7, $8
  }'
fi
