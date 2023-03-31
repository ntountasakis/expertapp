import * as functions from "firebase-functions";

export const getDefaultProfilePicUrl = functions.https.onCall(async (data, context) => {
    return "https://storage.googleapis.com/expert-app-backend.appspot.com/profilePics/Portrait_Placeholder.png";
});
