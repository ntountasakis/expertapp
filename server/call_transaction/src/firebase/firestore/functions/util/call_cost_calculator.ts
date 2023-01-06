export function calculateCostOfCallInCents({beginTimeUtcMs, endTimeUtcMs, centsPerMinute, centsStartCall}:
    {beginTimeUtcMs: number, endTimeUtcMs: number, centsPerMinute: number, centsStartCall: number}): number {
  if (beginTimeUtcMs == 0) {
    throw new Error("Cannot calculate cost of call. Begin time is 0");
  }
  if (endTimeUtcMs == 0) {
    throw new Error("Cannot calculate cost of call. End time is 0");
  }
  if (centsPerMinute == 0) {
    throw new Error("Cannot calculate cost of call. Cents per minute is 0");
  }
  const roundedElapsedTimeSeconds = Math.floor((endTimeUtcMs - beginTimeUtcMs) / 1000);
  const centsPerSecond = centsPerMinute / 60;
  const roundedTimeBasedCost = Math.floor(roundedElapsedTimeSeconds * centsPerSecond);
  const totalCost = roundedTimeBasedCost + centsStartCall;

  console.log(`Call length (s): ${roundedElapsedTimeSeconds}. Cost (cents): ${totalCost}`);
  return totalCost;
}

export function calculatePlatformFeeCents({costOfCallCents, platformFeePercent}:
  {costOfCallCents: number, platformFeePercent: number}): number {
  const platformFee = Math.round(costOfCallCents * (platformFeePercent / 100));
  console.log(`Platform fee (cents): ${platformFee}`);
  return platformFee;
}

export function calculatePaymentProcessorFeeCents({costOfCallCents, processorFeePercent, processorFlatFeeCents}:
  {costOfCallCents: number, processorFeePercent: number, processorFlatFeeCents: number}): number {
  const processorFee = Math.round((costOfCallCents * (processorFeePercent / 100)) + processorFlatFeeCents);
  console.log(`Processor fee (cents): ${processorFee}`);
  return processorFee;
}

export function calculateEarnedCents({costOfCallCents, platformFeeCents, processorFeeCents}:
  {costOfCallCents: number, platformFeeCents: number, processorFeeCents: number}): number {
  const earnedCents = costOfCallCents - platformFeeCents - processorFeeCents;
  console.log(`Earned (cents): ${earnedCents}`);
  return earnedCents;
}

export function calculateMaxCallLengthSec({centsPerMinute, centsStartCall, amountAuthorizedCents}:
  {centsPerMinute: number, centsStartCall: number, amountAuthorizedCents: number}): number {
  const centsRemainingAfterStart = amountAuthorizedCents - centsStartCall;
  if (centsRemainingAfterStart <= 0) {
    throw new Error(`Amount auth cents: ${amountAuthorizedCents} less than cents to start call ${centsStartCall}`);
  }
  const centsPerSecond = centsPerMinute / 60;
  const maxSeconds = Math.floor(centsRemainingAfterStart / centsPerSecond);
  if (maxSeconds <= 0) {
    throw new Error(`Amount auth cents ${amountAuthorizedCents} insufficent. Could only call for ${maxSeconds}`);
  }
  return maxSeconds;
}
