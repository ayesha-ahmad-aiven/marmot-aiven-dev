#!/bin/sh
# Adapts Aiven application env vars to Marmot's config.
# Marmot reads discrete MARMOT_DATABASE_* settings, not a connection URI,
# and has no setting for a CA file; pgx picks it up from PGSSLROOTCERT.
set -eu

if [ -n "${DATABASE_URL:-}" ]; then
    rest=${DATABASE_URL#*://}
    creds=${rest%%@*}
    hostpart=${rest#*@}
    hostport=${hostpart%%/*}
    dbpart=${hostpart#*/}
    export MARMOT_DATABASE_USER="${creds%%:*}"
    export MARMOT_DATABASE_PASSWORD="${creds#*:}"
    export MARMOT_DATABASE_HOST="${hostport%%:*}"
    export MARMOT_DATABASE_PORT="${hostport##*:}"
    export MARMOT_DATABASE_NAME="${dbpart%%\?*}"
fi

if [ -n "${PROJECT_CA_CERT:-}" ]; then
    ca_file="${TMPDIR:-/tmp}/aiven-project-ca.pem"
    printf '%s' "$PROJECT_CA_CERT" | base64 -d > "$ca_file"
    export PGSSLROOTCERT="$ca_file"
    export MARMOT_DATABASE_SSLMODE="${MARMOT_DATABASE_SSLMODE:-verify-full}"
fi

exec /usr/local/bin/marmot "$@"
