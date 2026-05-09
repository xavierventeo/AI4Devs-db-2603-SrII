-- DropIndex
DROP INDEX "Application_candidateId_idx";

-- CreateIndex
CREATE INDEX "Application_candidateId_status_idx" ON "Application"("candidateId", "status");
