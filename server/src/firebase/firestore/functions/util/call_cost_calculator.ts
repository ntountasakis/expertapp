export function calculateCostOfCallInCents({beginTimeUtcMs, endTimeUtcMs, centsPerMinute}:
    {beginTimeUtcMs: number, endTimeUtcMs: number, centsPerMinute: number}): number {
  const roundedElapsedTimeSeconds = Math.floor((endTimeUtcMs - beginTimeUtcMs) / 1000);
  const centsPerSecond = centsPerMinute / 60;
  const roundedCost = Math.floor(roundedElapsedTimeSeconds * centsPerSecond);

  console.log(`Call length (s): ${roundedElapsedTimeSeconds}. Cost (cents): ${roundedCost}`);
  return roundedCost;
}
