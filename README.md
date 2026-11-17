[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template/mindsdb-1?utm_medium=integration&utm_source=button&utm_campaign=mindsdb)

# MindsDB on Railway

This repo packages the official [MindsDB](https://github.com/mindsdb/mindsdb) image for one-click deployment on [Railway](https://railway.com).

MindsDB is an open-source AI query engine. You connect your databases, warehouses, SaaS apps and files once, then query them together with SQL, build knowledge bases for semantic search, and run agents and scheduled jobs over live data. It serves a web Studio, an HTTP API, an MCP server for AI clients and a MySQL-compatible API for BI tools.

## What it deploys

| Service | Builds from | Version |
|---|---|---|
| `MindsDB` | this repo (`Dockerfile`) | `mindsdb/mindsdb:v26.1.0` pinned by digest `sha256:163011c09299a95c97ce2e1b9f157683b3538c5b9167ddc258b95ac256c806bb` |

- One service with a Railway volume on `/root/mdb_storage`. MindsDB keeps everything there: its SQLite catalogue (projects, data source connections, models, views, jobs, agents, knowledge bases), uploaded files and logs. Redeploys and restarts keep it.
- A public Railway domain for the Studio, the HTTP API (`/api`), the MCP server (`/mcp/`) and the A2A endpoint (`/a2a`). Health check: `/api/util/ping`.
- A Railway TCP proxy for the MySQL API (container port `47335`, TLS on).

The wrapper `Dockerfile` and `start.sh` make small changes to the upstream image:

- MindsDB listens on Railway's `PORT` (default `47334`).
- It refuses to start without `MINDSDB_PASSWORD`. Without a password, MindsDB runs with no login at all, which would leave an open SQL engine with your data source credentials on the internet.
- The Studio files that ship in the image are kept outside the volume, so the volume doesn't hide them and nothing is downloaded at boot. GUI auto-update is off, so the Studio always matches the pinned version.

## Variables

| Variable | Default | What it does |
|---|---|---|
| `PORT` | `47334` | HTTP port; the Railway domain points at it |
| `MINDSDB_USERNAME` | `mindsdb` | Login user for the Studio, HTTP API and MySQL API |
| `MINDSDB_PASSWORD` | generated | Login password; required, MindsDB won't start without it |
| `MINDSDB_AUTH_TOKEN` | generated | Fixed bearer token for the HTTP API, MCP and A2A, so AI clients keep working after a restart |
| `FLASK_SECRET_KEY` | generated | Signs Studio session cookies, so you stay logged in across restarts |

The template asks nothing at deploy time. Optional settings you can add on the service (see the [MindsDB docs](https://docs.mindsdb.com/setup/environment-vars)):

- `MINDSDB_DEFAULT_LLM_API_KEY` (and `MINDSDB_DEFAULT_EMBEDDING_MODEL_API_KEY`): API keys for MindsDB's default LLM and embedding model, used by agents and knowledge bases.
- `MINDSDB_DB_CON`: a Postgres URL (for example `${{Postgres.DATABASE_URL}}`) to keep the catalogue in Postgres instead of SQLite.
- `KB_PGVECTOR_URL`: a Postgres URL with the pgvector extension, to store knowledge bases there instead of the built-in FAISS store on the volume.
- `MINDSDB_APIS`: which APIs start (default `http,mysql`).

## Using it

- Studio: `https://YOUR-DOMAIN/`. Sign in with `MINDSDB_USERNAME` and `MINDSDB_PASSWORD` (shown in the service's Variables tab).
- HTTP API: `POST https://YOUR-DOMAIN/api/sql/query` with `Authorization: Bearer <MINDSDB_AUTH_TOKEN>` and `{"query": "SELECT 1"}`.
- MCP clients (Claude, Cursor): `https://YOUR-DOMAIN/mcp/` with the header `Authorization: Bearer <MINDSDB_AUTH_TOKEN>`.
- MindsDB 26.1 revokes a token on logout (`POST /api/logout` with that token, which the Studio's sign-out may also send). If `MINDSDB_AUTH_TOKEN` stops working after a logout, restart the service to bring it back.
- MySQL clients and BI tools: the TCP proxy host and port from the service's Settings → Networking, with the same user and password.

## Updates

Railway notifies everyone who deployed this template when a change is merged to `main`. Each update bumps the pinned image in the `Dockerfile` and is described in [CHANGELOG.md](CHANGELOG.md), with breaking changes first. MindsDB migrates its catalogue on start, so a version bump needs no manual step unless the changelog says otherwise. Your volume is kept.
