export function isStringDefined(aString: string): boolean {
  return aString !== "" && aString !== undefined;
}

export function getUtcMsSinceEpoch(): number {
  return new Date().getTime();
}

export function convertMillisecondsToMinutesAndSeconds(milliseconds: number): { minutes: number, seconds: number } {
  const totalSeconds = Math.floor(milliseconds / 1000);
  const minutes = Math.floor(totalSeconds / 60);
  const seconds = totalSeconds % 60;

  return {minutes, seconds};
}
