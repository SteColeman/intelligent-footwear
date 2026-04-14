# Status Transition Regression Matrix

## Goal
Track the risky product-state transitions introduced by editable footwear status (`active`, `retired`, `archived`) and ensure they do not silently break other features.

## Scope
This matrix exists because the current prototype now includes:
- editable footwear metadata
- editable status
- editable primary photo
- default footwear behavior
- assignment behavior that should focus on active footwear
- Home / List / Insights / Detail views that should react to lifecycle state

## Core transitions

### 1. Active → Retired
Expected:
- item leaves active rotation views
- item remains visible in historical/inactive treatment
- item no longer appears in normal assignment targets
- detail explains retired meaning clearly
- photo remains visible
- existing history remains intact

Check:
- [ ] Footwear List moves item to inactive section
- [ ] Home no longer counts item in active rotation
- [ ] Insights no longer treats item as active insight subject
- [ ] Assign does not offer it in normal assignment flow
- [ ] Detail shows retired context
- [ ] Photo still renders
- [ ] Existing condition history remains visible

### 2. Active → Archived
Expected:
- same broad behavior as retired, but positioned more as reference-only
- not part of active/default behavior
- still visible historically

Check:
- [ ] Footwear List moves item to inactive section
- [ ] Home excludes item from active rotation
- [ ] Insights keeps it out of primary active story
- [ ] Assign excludes it from normal active assignment targets
- [ ] Detail shows archived context
- [ ] Photo still renders

### 3. Retired/Archived → Active
Expected:
- item re-enters active rotation views
- becomes assignable again
- can become meaningful in Home/Insights again
- detail/action affordances behave like active footwear again

Check:
- [ ] Footwear List returns item to active section
- [ ] Home includes item in active rotation if appropriate
- [ ] Insights can include it again if data warrants
- [ ] Assign can offer it again
- [ ] Detail restores active affordances (e.g. condition logging)

### 4. Default pair → Retired/Archived
Expected:
- app should not quietly treat inactive footwear as the active default without clear handling
- Home/default messaging should remain honest
- assignment/default behavior should remain sane

Check:
- [ ] Home no longer presents inactive default as if it were live default footwear
- [ ] Assign/default behavior remains sane
- [ ] Edit flow remains consistent after transition

### 5. Photo change while Active
Expected:
- list/detail refresh correctly
- relaunch still shows updated image
- no broken fallback state

Check:
- [ ] List updates
- [ ] Detail hero updates
- [ ] Relaunch preserves image
- [ ] No broken placeholder state

### 6. Photo change while Retired/Archived
Expected:
- still allowed if product keeps historical identity editable
- image updates cleanly
- inactive state messaging still preserved

Check:
- [ ] Detail photo controls still behave
- [ ] New image renders correctly
- [ ] Inactive presentation remains intact

### 7. Metadata edit after status change
Expected:
- nickname/brand/model/category edits still work
- status treatment remains coherent after save

Check:
- [ ] Edit flow saves cleanly
- [ ] List reflects changes
- [ ] Detail reflects changes
- [ ] Home/Insights remain sane

## Highest-risk combined regressions
These are the combinations most likely to expose inconsistencies:
- [ ] create pair with photo → set as default → archive it
- [ ] create two pairs → switch default → retire one → assign wear
- [ ] add photo → relaunch → change status → relaunch again
- [ ] retire pair with history → inspect Insights/Home/List/Detail consistency
- [ ] unarchive/reactivate pair → confirm it returns to active behavior everywhere

## Honest note
This matrix is not automated validation. It is a manual regression map for the current connected prototype while the product rules are still being actively defined.
