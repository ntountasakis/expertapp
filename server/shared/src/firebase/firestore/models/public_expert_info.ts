import { WeekAvailability } from "./expert_availability";

export interface PublicExpertInfo {
  firstName: string;
  lastName: string;
  description: string;
  majorExpertCategory: string;
  minorExpertCategory: string;
  profilePicUrl: string;
  runningSumReviewRatings: number;
  numReviews: number;
  availability: WeekAvailability;
  inCall: boolean;
  isOnline: boolean;
}