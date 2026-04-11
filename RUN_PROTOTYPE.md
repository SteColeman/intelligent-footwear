# Run Prototype

This is an early connected prototype with:
- SwiftUI iOS source tree
- Fastify backend
- Prisma/PostgreSQL data layer
- Apple Health / HealthKit integration scaffolding

See also:
- `HANDOFF_READINESS.md`
- `MOVE_TO_MAC_THRESHOLD.md`
- `FIRST_REPO_BOOTSTRAP.md`

## Backend setup
```bash
cd backend
cp .env.example .env
npm install
npm run prisma:generate
```

## Database requirement
A reachable PostgreSQL instance is required before these will work:
```bash
npm run prisma:migrate
npm run seed
npm run dev
```

If Docker is available, the intended path is:
```bash
docker compose up -d
```

If Docker is **not** available in the current environment, use another reachable PostgreSQL runtime.
See:
- `backend/ENVIRONMENT_LIMITATIONS.md`

## iOS side
The iOS source tree exists, but a real Xcode project container still needs to be created on Mac/Xcode.
See:
- `ios-app/XCODE_RUN_SETUP.md`
- `ios-app/MAC_HANDOFF_CHECKLIST.md`

## Honest status
This is a connected prototype moving toward test readiness, not yet a fully validated MVP.
