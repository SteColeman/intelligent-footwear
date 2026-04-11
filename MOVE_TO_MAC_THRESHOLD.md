# Move to Mac Threshold

## Purpose
This file answers one blunt question:

**When is it worth stopping local cleanup and moving the project onto a Mac for real Xcode/backend testing?**

## Current answer
**Not yet, but closer than before.**

## Move-to-Mac threshold
Move the project to Mac when all of these are true:

### Packaging
- repo can be initialized or placed in the intended git repo cleanly
- `.gitignore` is in place
- first commit boundary is straightforward

### Backend readiness
- backend docs/contracts match the implemented route surface
- migrate/seed/smoke path is clear
- the only major remaining backend blocker is lack of real PostgreSQL runtime in this Linux environment

### iOS readiness
- SwiftUI source tree is coherent enough that the Mac session should test Xcode truth, not obvious cleanup
- navigation/app flow is broadly sane
- handoff docs clearly explain target wiring, HealthKit, Info.plist, and backend URL setup

## What still keeps this below threshold right now
- no checked-in Xcode project shell yet
- no DB-backed smoke validation completed yet
- no git repo boundary created yet

## Practical interpretation
If the next step on Mac would mostly be:
- create/open Xcode project
- wire app target
- run backend with real DB
- start real compile/runtime validation

then the threshold is close.

If the next step on Mac would still mostly be:
- fix obvious source chaos
- rewrite docs to match code
- clean packaging confusion

then it is not ready.

## Current honest read
The project is moving **toward** the threshold, but is still short of it.
