#!/usr/bin/env bash
# Railway wrapper for MindsDB: writes the config file, checks the login, starts MindsDB.
set -euo pipefail

export PORT="${PORT:-47334}"
export MINDSDB_MYSQL_PORT="${MINDSDB_MYSQL_PORT:-47335}"
export MINDSDB_DATA_DIR="${MINDSDB_DATA_DIR:-/root/mdb_storage}"
export MINDSDB_USERNAME="${MINDSDB_USERNAME:-mindsdb}"

# Never start without a login: MindsDB's HTTP API, Studio, MCP and MySQL API
# are open to anyone when no password is set.
if [ -z "${MINDSDB_PASSWORD:-}" ]; then
  echo "MINDSDB_PASSWORD is empty. Set it (the template generates one) and redeploy." >&2
  exit 1
fi

mkdir -p "$MINDSDB_DATA_DIR"

cat > /root/mindsdb_config.json <<JSON
{
  "config_version": "1.4",
  "paths": {
    "root": "${MINDSDB_DATA_DIR}",
    "static": "/opt/mindsdb-gui"
  },
  "gui": { "open_on_start": false, "autoupdate": false },
  "debug": false,
  "integrations": {},
  "api": {
    "http": { "host": "0.0.0.0", "port": "${PORT}" },
    "mysql": { "host": "0.0.0.0", "port": "${MINDSDB_MYSQL_PORT}", "database": "mindsdb", "ssl": true }
  }
}
JSON

echo "Starting MindsDB $(python -c 'import mindsdb; print(mindsdb.__version__)' 2>/dev/null || true): HTTP on ${PORT}, MySQL on ${MINDSDB_MYSQL_PORT}, data in ${MINDSDB_DATA_DIR}"
exec python -Im mindsdb --config=/root/mindsdb_config.json --api="${MINDSDB_APIS:-http,mysql}"
