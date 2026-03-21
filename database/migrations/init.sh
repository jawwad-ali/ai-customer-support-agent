#!/usr/bin/env bash
# =============================================================================
# Database Initialization Script
# Runs schema migration and optionally seeds the knowledge base.
#
# Used by:
#   - Docker Compose: mounted into postgres /docker-entrypoint-initdb.d/
#   - Kubernetes: executed by the API init container
#
# Environment:
#   PGHOST, PGPORT, PGUSER, PGPASSWORD, PGDATABASE — PostgreSQL connection
#   OPENAI_API_KEY (optional) — if set, runs knowledge base seeding
#   DATABASE_URL (optional)  — used by the Python seed script
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "[init.sh] Starting database initialization..."

# -------------------------------------------------------
# Step 1: Run the SQL schema migration
# -------------------------------------------------------
echo "[init.sh] Applying 001_initial_schema.sql..."

psql -v ON_ERROR_STOP=1 \
    -h "${PGHOST:-localhost}" \
    -p "${PGPORT:-5432}" \
    -U "${PGUSER:-postgres}" \
    -d "${PGDATABASE:-crm}" \
    -f "${SCRIPT_DIR}/001_initial_schema.sql"

echo "[init.sh] Schema migration complete."

# -------------------------------------------------------
# Step 2: Optionally seed the knowledge base
# Requires OPENAI_API_KEY for embedding generation.
# Skipped gracefully if the key is not set.
# -------------------------------------------------------
if [ -n "${OPENAI_API_KEY:-}" ]; then
    echo "[init.sh] OPENAI_API_KEY detected — seeding knowledge base..."

    # Build DATABASE_URL from PG* vars if not already set
    export DATABASE_URL="${DATABASE_URL:-postgresql://${PGUSER:-postgres}:${PGPASSWORD:-postgres}@${PGHOST:-localhost}:${PGPORT:-5432}/${PGDATABASE:-crm}}"

    python -m database.migrations.002_seed_knowledge_base

    echo "[init.sh] Knowledge base seeding complete."
else
    echo "[init.sh] OPENAI_API_KEY not set — skipping knowledge base seeding."
    echo "[init.sh] You can seed later with: python -m database.migrations.002_seed_knowledge_base"
fi

echo "[init.sh] Database initialization finished."
