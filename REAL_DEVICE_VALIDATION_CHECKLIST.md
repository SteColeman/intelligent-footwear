# Real Device Validation Checklist

## Goal
Use this checklist once the app is installed on a physical iPhone and the backend is reachable from that device.

## Setup
- [ ] latest repo pulled on Mac
- [ ] latest backend running on Mac or reachable host
- [ ] backend URL in app points to reachable machine (not `localhost` from phone)
- [ ] phone and backend can reach each other
- [ ] app installed on physical device via Xcode

## Device flow
- [ ] first launch works
- [ ] onboarding completes
- [ ] app relaunch does not reopen onboarding
- [ ] Apple Health permission path behaves sensibly
- [ ] add footwear works
- [ ] add footwear with photo works
- [ ] photo preview feels acceptable on device
- [ ] list/detail photo rendering feels acceptable on device
- [ ] change photo from detail works
- [ ] remove photo from detail works
- [ ] edit footwear metadata works
- [ ] change footwear status works
- [ ] Home reflects active/inactive state correctly
- [ ] List reflects active/inactive state correctly
- [ ] Insights reflects active/inactive state correctly
- [ ] Assign only offers active footwear in normal assignment flow
- [ ] import demo or live activity works
- [ ] assign flow works
- [ ] condition log works for active footwear
- [ ] condition log still works for retired footwear if intended
- [ ] archived footwear cannot create fresh condition logs
- [ ] inactive footwear is not treated like active footwear in the main UI

## Relaunch / persistence
- [ ] force close and reopen app
- [ ] onboarding state still correct
- [ ] footwear still present
- [ ] photos still present
- [ ] active/inactive states still present
- [ ] detail/edit flows still work

## Away-from-laptop test questions
- [ ] backend remains reachable when away from Mac/home network (if relevant)
- [ ] app still behaves sensibly after hours away from laptop
- [ ] no obvious broken image / broken bootstrap / broken backend URL state appears

## Current known caveats
- local photo persistence is prototype-grade
- backend reachability strategy still matters for full away-from-laptop testing
- this is still a connected prototype, not production packaging
