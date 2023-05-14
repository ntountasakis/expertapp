import {BaseCallState} from "../../../../call_state/common/base_call_state";

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
  return totalCost;
}

export function calculatePreAuthAmountForDesiredCallLength({desiredLengthSeconds, centsStartCall, centsPerMinute}:
  {desiredLengthSeconds: number, centsStartCall: number, centsPerMinute: number}): number {
  return calculateCostOfCallInCents({beginTimeUtcMs: 1000, endTimeUtcMs: 1000 + (desiredLengthSeconds * 1000),
    centsPerMinute: centsPerMinute, centsStartCall: centsStartCall});
}

export async function calculatePlatformFeeCents({costOfCallCents, platformFeePercent, callState}:
  {costOfCallCents: number, platformFeePercent: number, callState: BaseCallState}): Promise<number> {
  const platformFee = Math.round(costOfCallCents * (platformFeePercent / 100));
  await callState.log(`Platform fee (cents): ${platformFee}`);
  return platformFee;
}

export async function calculateEarnedCents({costOfCallCents, platformFeeCents, callState}:
  {costOfCallCents: number, platformFeeCents: number, callState: BaseCallState}): Promise<number> {
  const earnedCents = costOfCallCents - platformFeeCents;
  await callState.log(`Earned (cents): ${earnedCents}`);
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
