import {BaseCallState} from "../../../../call_state/common/base_call_state";

export function calculateCostOfCallInCents({beginTimeUtcMs, endTimeUtcMs, centsPerMinute, centsStartCall, callState}:
    {beginTimeUtcMs: number, endTimeUtcMs: number, centsPerMinute: number, centsStartCall: number, callState: BaseCallState}): number {
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

  callState.log(`Call length (s): ${roundedElapsedTimeSeconds}. Cost (cents): ${totalCost}`);
  return totalCost;
}

export function calculatePlatformFeeCents({costOfCallCents, platformFeePercent, callState}:
  {costOfCallCents: number, platformFeePercent: number, callState: BaseCallState}): number {
  const platformFee = Math.round(costOfCallCents * (platformFeePercent / 100));
  callState.log(`Platform fee (cents): ${platformFee}`);
  return platformFee;
}

export function calculatePaymentProcessorFeeCents({costOfCallCents, processorFeePercent, processorFlatFeeCents, callState}:
  {costOfCallCents: number, processorFeePercent: number, processorFlatFeeCents: number, callState: BaseCallState}): number {
  const processorFee = Math.round((costOfCallCents * (processorFeePercent / 100)) + processorFlatFeeCents);
  callState.log(`Processor fee (cents): ${processorFee}`);
  return processorFee;
}

export function calculateEarnedCents({costOfCallCents, platformFeeCents, processorFeeCents, callState}:
  {costOfCallCents: number, platformFeeCents: number, processorFeeCents: number, callState: BaseCallState}): number {
  const earnedCents = costOfCallCents - platformFeeCents - processorFeeCents;
  callState.log(`Earned (cents): ${earnedCents}`);
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
