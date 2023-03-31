import * as functions from "firebase-functions";
import { StoragePaths } from "../../../shared/src/firebase/storage/storage_paths";

export const getDefaultProfilePicUrl = functions.https.onCall(async (data, context) => {
    return StoragePaths.DEFAULT_PROFILE_PIC_URL;
});
