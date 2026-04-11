# Environment Limitations

## Current local limitation in this build environment
The current Linux build environment used for this prototype does **not** have:
- `docker`
- `podman`
- local `postgres`
- local `psql`

That means the backend cannot complete its real database-backed smoke run here yet, because Prisma migrate/seed requires a running PostgreSQL instance.

## What *does* work here
- backend dependency install (`npm install`)
- Prisma client generation (`npm run prisma:generate`)
- route/code hardening
- iOS source structure work
- docs/runbook cleanup

## What is blocked specifically by environment
- `docker compose up -d`
- Prisma migrate against `localhost:5432`
- seed against `localhost:5432`
- full live API smoke pass

## Meaning
The prototype can still be improved in code, but it should **not** be claimed as backend-validated in this environment until PostgreSQL is actually available.
