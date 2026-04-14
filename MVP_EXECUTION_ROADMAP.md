# MVP Execution Roadmap

## Goal
Move the project from the current connected prototype to a finished MVP that:
- connects to a hosted backend and hosted database
- runs on a physical iPhone
- supports repeatable product testing
- remains honest about what is prototype-grade vs production-grade

## Finished MVP definition
A user can:
- complete onboarding once without regression
- add footwear
- edit footwear metadata
- add/change/remove primary photo
- mark footwear active / retired / archived
- connect Apple Health or use demo import
- assign wear to active footwear
- log condition
- inspect Home / List / Detail / Assign / Insights coherently
- relaunch the app without losing meaningful state
- use the app on a physical device against a hosted backend + DB

## Phase A — Stabilize the current prototype baseline
1. Freeze and push current known-good repo state
2. Build-safety sweep for touched SwiftUI/backend files
3. Xcode target-membership sweep for new files
4. Backend route sanity sweep
5. Current docs sync pass
6. Commit/push baseline stabilization checkpoint

## Phase B — Complete core MVP behavior
7. Finalize onboarding behavior
8. Finalize default-footwear behavior
9. Finalize assignment rules
10. Finalize condition-log rules for active/inactive footwear
11. Finalize lifecycle-state semantics across the product
12. Finalize photo feature for MVP-level use
13. Finalize metadata editing coverage
14. Finalize archive/retire lifecycle polish
15. Finalize Home behavior
16. Finalize Detail behavior
17. Finalize Insights behavior
18. Finalize Settings behavior
19. Finalize Create/Edit UX cleanup
20. Commit/push core MVP behavior checkpoint

## Phase C — Hosted backend + hosted DB
21. Choose deployment target
22. Provision hosted Postgres
23. Prepare backend env for hosted runtime
24. Apply Prisma migrations to hosted DB
25. Seed hosted DB if needed
26. Deploy backend service
27. Verify hosted endpoints
28. Verify demo-user flow against hosted DB
29. Decide image-storage strategy for hosted mode
30. Add hosted media path if needed
31. Point app config at hosted backend
32. Commit/push hosted-runtime checkpoint

## Phase D — Physical device readiness
33. Real-device build sanity
34. Confirm backend reachability from phone
35. Install app on physical device
36. First-launch sanity on device
37. Onboarding on device
38. Photo flow on device
39. Home/List/Detail/Assign/Insights sanity on device
40. Relaunch persistence on device
41. Repeat-flow sanity on device
42. Away-from-laptop readiness check
43. Commit/push physical-device validation checkpoint

## Phase E — MVP hardening and signoff
44. Regression cycle 1
45. Fix bugs from cycle 1
46. Refactor cycle 1
47. Regression cycle 2
48. Fix bugs from cycle 2
49. UX/performance rough-edge sweep
50. Docs finalization pass
51. Final MVP-ready checkpoint

## Testing cadence
- test each changed flow after each meaningful slice
- run broader regression every 2–4 slices
- run full regression at each phase boundary
- run repeated-flow regression on physical device once hosted backend is live

## Refactor cadence
- once after baseline stabilization
- once mid-core-behavior work
- once after hosted backend integration
- once before MVP signoff

## Commit/push cadence
- commit every meaningful slice
- push every 1–3 commits or at any real testing boundary
- always push before Mac/device validation sessions
