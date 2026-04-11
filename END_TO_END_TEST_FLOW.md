# End-to-End Test Flow

## Goal
Exercise the current prototype loop from backend boot to app interaction.

See also:
- `HANDOFF_READINESS.md`
- `MOVE_TO_MAC_THRESHOLD.md`
- `ios-app/MAC_HANDOFF_CHECKLIST.md`

## Backend
1. Start Postgres
2. Install backend deps
3. Run Prisma generate
4. Run migrations
5. Seed demo user
6. Start backend server
7. Verify:
   - `/health`
   - `/me?authProviderId=demo-user`

## App
1. Open the Xcode project once created/wired
2. Confirm backend URL is reachable
3. Launch app
4. Let app bootstrap demo user
5. Complete onboarding
6. Connect Apple Health or skip
7. Add first footwear
8. Import demo data or live today data
9. Confirm unassigned wear appears
10. Assign wear to footwear
11. Log condition
12. Refresh Home and Insights

## Expected current success state
- footwear exists in backend
- imported wear exists in backend
- assignment exists in backend
- condition log exists in backend
- lifecycle summary exists in backend
- Home / Insights return non-empty useful state

## Known prototype caveats
- still prototype auth
- still prototype app packaging path
- still early-stage validation quality
