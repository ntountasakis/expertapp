export function isStringDefined(aString: string): boolean {
  return aString !== "" && aString !== undefined;
}

export function getUtcMsSinceEpoch(): number {
  return new Date().getTime();
}
