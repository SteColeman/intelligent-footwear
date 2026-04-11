# Quick API Smoke Tests

Run after backend setup:

```bash
curl http://localhost:3000/health
curl -X POST http://localhost:3000/dev/bootstrap-demo-user
curl "http://localhost:3000/me?authProviderId=demo-user"
```

Use returned `userId` for the following:

```bash
curl -X POST http://localhost:3000/footwear \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "USER_ID_HERE",
    "brand": "New Balance",
    "model": "990v6",
    "nickname": "Everyday Trainers",
    "category": "trainers",
    "isDefaultFallback": true
  }'
```

```bash
curl "http://localhost:3000/footwear?userId=USER_ID_HERE"
```

```bash
curl -X POST http://localhost:3000/health/import-batch \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "USER_ID_HERE",
    "importedAt": "2026-04-07T10:00:00Z",
    "startRange": "2026-04-07T00:00:00Z",
    "endRange": "2026-04-08T00:00:00Z",
    "sourceDevice": "iPhone",
    "events": [
      {
        "eventDate": "2026-04-07T00:00:00Z",
        "eventType": "mixed_daily_activity",
        "stepsCount": 7000,
        "distanceKm": 5.1,
        "startTime": "2026-04-07T00:00:00Z",
        "endTime": "2026-04-07T23:59:59Z",
        "sourceLabel": "demo"
      }
    ]
  }'
```

```bash
curl "http://localhost:3000/wear-events/unassigned?userId=USER_ID_HERE"
```

Use returned `wearEventId` and `footwearId` for assignment:

```bash
curl -X POST http://localhost:3000/assignments \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "USER_ID_HERE",
    "wearEventId": "WEAR_EVENT_ID_HERE",
    "footwearItemId": "FOOTWEAR_ID_HERE",
    "assignmentMethod": "manual",
    "assignmentConfidence": 1,
    "confirmedByUser": true
  }'
```

```bash
curl -X POST http://localhost:3000/condition-logs \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "USER_ID_HERE",
    "footwearItemId": "FOOTWEAR_ID_HERE",
    "comfortScore": 4,
    "cushioningScore": 4,
    "supportScore": 4,
    "gripScore": 4,
    "upperConditionScore": 4,
    "overallConfidenceScore": 4,
    "painFlag": false
  }'
```

```bash
curl "http://localhost:3000/footwear/FOOTWEAR_ID_HERE?userId=USER_ID_HERE"
curl "http://localhost:3000/footwear/FOOTWEAR_ID_HERE/condition-logs?userId=USER_ID_HERE"
curl "http://localhost:3000/footwear/FOOTWEAR_ID_HERE/lifecycle-summary?userId=USER_ID_HERE"
```

```bash
curl "http://localhost:3000/home-summary?userId=USER_ID_HERE"
curl "http://localhost:3000/insights?userId=USER_ID_HERE"
```
