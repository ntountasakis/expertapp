export interface DayAvailability {
    isAvailable: boolean;
    startHourUtc: number;
    startMinuteUtc: number;
    endHourUtc: number;
    endMinuteUtc: number;
}

export interface WeekAvailability {
    mondayAvailability: DayAvailability;
    tuesdayAvailability: DayAvailability;
    wednesdayAvailability: DayAvailability;
    thursdayAvailability: DayAvailability;
    fridayAvailability: DayAvailability;
    saturdayAvailability: DayAvailability;
    sundayAvailability: DayAvailability;
}
