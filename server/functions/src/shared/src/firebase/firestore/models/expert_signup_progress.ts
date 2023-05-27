
export interface ExpertSignupProgress {
    updatedProfilePic: boolean;
    updatedProfileDescription: boolean;
    updatedExpertCategory: boolean;
    updatedCallRate: boolean;
    updatedAvailability: boolean;
    updatedSmsPreferences: boolean;
}

export function isExpertSignupProgressComplete(signupProgress: ExpertSignupProgress): boolean {
  return signupProgress.updatedProfilePic && signupProgress.updatedProfileDescription &&
        signupProgress.updatedExpertCategory && signupProgress.updatedCallRate && signupProgress.updatedAvailability &&
        signupProgress.updatedSmsPreferences;
}
