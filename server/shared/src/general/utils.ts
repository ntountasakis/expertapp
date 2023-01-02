export function isStringDefined(aString: string): boolean {
    return aString !== "" && aString !== undefined;
}

export function getUtcMsSinceEpoch(): number {
    var date = new Date();
    var now_utc = Date.UTC(date.getUTCFullYear(), date.getUTCMonth(),
        date.getUTCDate(), date.getUTCHours(),
        date.getUTCMinutes(), date.getUTCSeconds());
    return now_utc;
}