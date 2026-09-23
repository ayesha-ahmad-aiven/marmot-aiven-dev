# marmot-aiven-dev

Thin wrapper to run [Marmot](https://marmotdata.io/) as an Aiven application
service. Builds `FROM ghcr.io/marmotdata/marmot:<version>`; no fork.

`entrypoint.sh` maps the Aiven PostgreSQL integration (`DATABASE_URL`,
`PROJECT_CA_CERT`) to Marmot's `MARMOT_DATABASE_*` settings and enables
`sslmode=verify-full`.

Required app env vars:

- `MARMOT_SERVER_ENCRYPTION_KEY` (secret): `openssl rand -base64 32`
- `MARMOT_TELEMETRY_ENABLED=false`

Default login is `admin` / `admin`; Marmot forces a password change on first
login.
