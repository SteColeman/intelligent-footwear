# End-to-End Test Flow

## Goal
Exercise the current connected prototype loop from backend boot to real app interaction, including the newer onboarding persistence and footwear photo flows.

See also:
- `HANDOFF_READINESS.md`
- `VALIDATION_STATUS.md`
- `ios-app/PROJECT_STATUS.md`

## Backend
1. Start PostgreSQL on the active validation machine
2. Install backend deps if needed
3. Run Prisma generate
4. Run migrations
5. Seed if needed
6. Start backend server
7. Verify:
   - `GET /health`
   - `GET /me?authProviderId=demo-user`
   - `POST /me/onboarding-complete` is live
   - `PATCH /footwear/:id/photo` is live

## App
1. Open the checked-in Xcode project
2. Confirm backend URL is reachable from simulator/device
3. Launch app
4. Let app bootstrap demo user
5. Complete onboarding
6. Relaunch app and confirm onboarding does **not** return
7. Connect Apple Health or skip intentionally
8. Add first footwear
9. Optionally add photo during create flow
10. Add second footwear
11. Confirm default footwear behavior is sane
12. Import demo data or live today data
13. Confirm unassigned wear appears
14. Assign wear to footwear
15. Open Footwear List and inspect object identity / photo rendering
16. Open Footwear Detail
17. Change primary photo from detail
18. Remove primary photo from detail
19. Log condition
20. Refresh Home and Insights
21. Relaunch app again and check:
    - onboarding still stays complete
    - photo state still renders correctly
    - Home / list / detail still make sense

## Expected current success state
- onboarding status persists after completion
- footwear exists in backend
- optional footwear photo exists as usable identity in prototype
- imported wear exists in backend
- assignment exists in backend
- condition log exists in backend
- lifecycle summary exists in backend
- Home / Insights return non-empty useful state when expected
- repeated relaunch does not obviously break the prototype loop

## Known prototype caveats
- still prototype auth
- still connected-prototype packaging, not production distribution
- photo handling is local prototype persistence, not durable cross-device media storage
- validation quality still depends on repeated Mac/device runs, not automated coverage
