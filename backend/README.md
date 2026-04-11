# Footwear Intelligence Backend

## Setup
```bash
cp .env.example .env
docker compose up -d
npm install
npm run prisma:generate
npm run prisma:migrate
npm run seed
npm run dev
```

## Important environment note
If Docker or local PostgreSQL is unavailable, the backend cannot complete its real database-backed smoke run.
See:
- `ENVIRONMENT_LIMITATIONS.md`

## Repo packaging note
For version control / GitHub handoff:
- commit source, schema, docs, and lockfiles
- do **not** commit `node_modules/`
- do **not** commit `.env`

The build folder `.gitignore` is set up accordingly.

## Build note
The backend also has a TypeScript build path:
```bash
npm run build
npm run start
```

That path is useful later for cleaner packaging/runtime validation once the database runtime is available.

## Demo user
The prototype currently uses:
- `demo-user`

Seed command creates that user.
You can also bootstrap it via:
```bash
curl -X POST http://localhost:3000/dev/bootstrap-demo-user
```

## Quick checks
```bash
curl http://localhost:3000/health
curl http://localhost:3000/
curl "http://localhost:3000/me?authProviderId=demo-user"
```

For a fuller sequence use:
- `QUICK_API_SMOKE_TESTS.md`

## Error shape
App-level errors return:
```json
{
  "error": {
    "code": "APP_ERROR",
    "message": "..."
  }
}
```

Validation failures return:
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "...",
    "details": []
  }
}
```

## Current endpoints
- `GET /health`
- `GET /`
- `GET /me?authProviderId=...`
- `POST /dev/bootstrap-demo-user`
- `GET /footwear?userId=...`
- `POST /footwear`
- `GET /footwear/:id?userId=...`
- `POST /health/import-batch`
- `GET /wear-events/unassigned?userId=...`
- `POST /assignments`
- `DELETE /assignments/:id`
- `POST /assignments/bulk-default`
- `POST /condition-logs`
- `GET /footwear/:id/condition-logs?userId=...`
- `GET /footwear/:id/lifecycle-summary?userId=...`
- `GET /home-summary?userId=...`
- `GET /insights?userId=...`

## Current milestone
Prototype backend supports:
- demo-user bootstrapping
- footwear CRUD
- health import
- assignment
- condition logs
- lifecycle summaries
- home/insights summaries
- partial execution validation

## Current honest status
- dependencies install cleanly
- Prisma client generation works
- validation errors are surfaced more cleanly
- root endpoint reflects connected-prototype state
- full smoke pass is still blocked here by missing PostgreSQL runtime
