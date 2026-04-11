# First Repo Bootstrap

## Purpose
Use this when turning the current `mvp-build/` folder into a real git-tracked project for GitHub/Mac handoff.

## Preconditions
Before doing this, verify:
- `.gitignore` is present
- obvious runtime/generated clutter is excluded
- docs reflect the current prototype honestly

## Recommended bootstrap sequence
From `mvp-build/`:

```bash
git init
git add .
git status
```

Review the staged set and confirm these are **not** included:
- `backend/node_modules/`
- `backend/.env`
- any local editor junk
- any local Xcode build junk

If the staged set looks clean:

```bash
git commit -m "Initial connected prototype build"
```

Then add the remote and push:

```bash
git remote add origin <YOUR_GITHUB_REPO_URL>
git branch -M main
git push -u origin main
```

## After push
On the Mac:
1. clone the repo
2. run backend setup against real PostgreSQL
3. create/open the Xcode project
4. wire HealthKit and Info.plist
5. begin the first real build/test pass

## Honest note
This bootstrap step does **not** mean the prototype is fully validated.
It only means the project is packaged cleanly enough to move into serious Mac/Xcode testing.
