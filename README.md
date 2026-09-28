# marmot-aiven-dev

Run [Marmot](https://marmotdata.io/) on Aiven Runtime backed by Aiven for
PostgreSQL. Builds `FROM ghcr.io/marmotdata/marmot:<version>`; no fork.

## Files

- `compose.yaml`: the Runtime manifest. `marmot` (`build: .`) becomes an
  application service, `marmot-pg` (`postgres` image) becomes an Aiven for
  PostgreSQL service, and `DATABASE_URL` referencing `@marmot-pg` becomes an
  `application_service_credential` integration that injects the Aiven
  connection string into `DATABASE_URL`.
- `Dockerfile`: wraps the upstream image with nginx and `entrypoint.sh`.
- `entrypoint.sh`: maps `DATABASE_URL` to Marmot's `MARMOT_DATABASE_*`
  settings. Uses `sslmode=verify-full` when `PROJECT_CA_CERT` is injected,
  otherwise the URL's `sslmode` (`require` on Aiven). Starts nginx on `:8080`
  in front of Marmot on `127.0.0.1:8081`.
- `nginx.conf`: rewrites `Host` to `localhost` for `/api/v1/mcp` only, so the
  MCP endpoint's localhost protection accepts proxied requests.

## Deploy on Aiven Runtime

1. Aiven Console > project > Runtime > deploy from GitHub, select this repo,
   branch `main`, manifest `compose.yaml`.
2. Accept both suggested services (`marmot` application, `marmot-pg`
   PostgreSQL) and pick plans and cloud.
3. Set `MARMOT_SERVER_ENCRYPTION_KEY` as a secret on `marmot`
   (`openssl rand -base64 32`). The Compose value is empty on purpose; do not
   commit the key. Losing it makes stored ingestion credentials unreadable.
4. Open the app URL, log in with `admin` / `admin`, and change the password.

Plans, cloud and secrets are not in the manifest; they are chosen at deploy
time.

## Run locally

```sh
cp .env.example .env   # then set MARMOT_SERVER_ENCRYPTION_KEY
docker compose up --build
```

Marmot is at http://localhost:8080.
