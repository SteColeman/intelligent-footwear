-- CreateTable
CREATE TABLE "User" (
    "id" TEXT NOT NULL,
    "authProviderId" TEXT NOT NULL,
    "timezone" TEXT,
    "locale" TEXT,
    "onboardingStatus" TEXT NOT NULL,
    "healthConnectionStatus" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "User_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "FootwearItem" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "brand" TEXT NOT NULL,
    "model" TEXT NOT NULL,
    "nickname" TEXT,
    "category" TEXT NOT NULL,
    "purchaseDate" TIMESTAMP(3),
    "startUseDate" TIMESTAMP(3),
    "retireDate" TIMESTAMP(3),
    "targetSteps" INTEGER,
    "targetDistanceKm" DOUBLE PRECISION,
    "status" TEXT NOT NULL,
    "isDefaultFallback" BOOLEAN NOT NULL DEFAULT false,
    "photoUrl" TEXT,
    "notes" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "FootwearItem_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "HealthImportBatch" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "importedAt" TIMESTAMP(3) NOT NULL,
    "sourceDevice" TEXT,
    "startRange" TIMESTAMP(3) NOT NULL,
    "endRange" TIMESTAMP(3) NOT NULL,
    "importStatus" TEXT NOT NULL,
    "rawSummaryJson" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "HealthImportBatch_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "WearEvent" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "importBatchId" TEXT,
    "eventDate" TIMESTAMP(3) NOT NULL,
    "startTime" TIMESTAMP(3),
    "endTime" TIMESTAMP(3),
    "eventType" TEXT NOT NULL,
    "stepsCount" INTEGER,
    "distanceKm" DOUBLE PRECISION,
    "assignmentStatus" TEXT NOT NULL,
    "sourceLabel" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "WearEvent_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Assignment" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "wearEventId" TEXT NOT NULL,
    "footwearItemId" TEXT NOT NULL,
    "assignmentMethod" TEXT NOT NULL,
    "assignmentConfidence" DOUBLE PRECISION,
    "confirmedByUser" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Assignment_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ConditionLog" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "footwearItemId" TEXT NOT NULL,
    "comfortScore" INTEGER NOT NULL,
    "cushioningScore" INTEGER NOT NULL,
    "supportScore" INTEGER NOT NULL,
    "gripScore" INTEGER NOT NULL,
    "upperConditionScore" INTEGER NOT NULL,
    "waterproofingScore" INTEGER,
    "overallConfidenceScore" INTEGER NOT NULL,
    "painFlag" BOOLEAN NOT NULL DEFAULT false,
    "notes" TEXT,
    "photoUrl" TEXT,
    "loggedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ConditionLog_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "LifecycleSummary" (
    "id" TEXT NOT NULL,
    "footwearItemId" TEXT NOT NULL,
    "totalSteps" INTEGER NOT NULL DEFAULT 0,
    "totalDistanceKm" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "assignedDaysCount" INTEGER NOT NULL DEFAULT 0,
    "lastUsedAt" TIMESTAMP(3),
    "lifecycleProgressPct" DOUBLE PRECISION,
    "estimatedRemainingSteps" INTEGER,
    "estimatedRemainingDistanceKm" DOUBLE PRECISION,
    "retirementRiskLevel" TEXT NOT NULL,
    "confidenceScore" DOUBLE PRECISION,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "LifecycleSummary_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "User_authProviderId_key" ON "User"("authProviderId");

-- CreateIndex
CREATE UNIQUE INDEX "Assignment_wearEventId_key" ON "Assignment"("wearEventId");

-- CreateIndex
CREATE UNIQUE INDEX "LifecycleSummary_footwearItemId_key" ON "LifecycleSummary"("footwearItemId");

-- AddForeignKey
ALTER TABLE "FootwearItem" ADD CONSTRAINT "FootwearItem_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "HealthImportBatch" ADD CONSTRAINT "HealthImportBatch_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "WearEvent" ADD CONSTRAINT "WearEvent_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "WearEvent" ADD CONSTRAINT "WearEvent_importBatchId_fkey" FOREIGN KEY ("importBatchId") REFERENCES "HealthImportBatch"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Assignment" ADD CONSTRAINT "Assignment_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Assignment" ADD CONSTRAINT "Assignment_wearEventId_fkey" FOREIGN KEY ("wearEventId") REFERENCES "WearEvent"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Assignment" ADD CONSTRAINT "Assignment_footwearItemId_fkey" FOREIGN KEY ("footwearItemId") REFERENCES "FootwearItem"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ConditionLog" ADD CONSTRAINT "ConditionLog_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ConditionLog" ADD CONSTRAINT "ConditionLog_footwearItemId_fkey" FOREIGN KEY ("footwearItemId") REFERENCES "FootwearItem"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "LifecycleSummary" ADD CONSTRAINT "LifecycleSummary_footwearItemId_fkey" FOREIGN KEY ("footwearItemId") REFERENCES "FootwearItem"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
