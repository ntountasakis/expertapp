import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { v4 as uuidv4 } from "uuid";
import { Bucket } from "@google-cloud/storage";
import { getProfilePicBucket } from "../../../shared/src/firebase/storage/functions/get_profile_pic_bucket_ref";
import { updateProfilePicUrl } from "../../../shared/src/firebase/firestore/functions/update_profile_pic_url";
import { StoragePaths } from "../../../shared/src/firebase/storage/storage_paths";
import { Logger } from "../../../shared/src/google_cloud/google_cloud_logger";

export const updateProfilePicture = functions.https.onCall(async (data, context) => {
  if (context.auth == null) {
    throw new Error("Cannot call by unauthorized users");
  }
  const uid = context.auth.uid;
  const pictureBytes: Buffer = Buffer.from(data.pictureBytes);
  const publicUrl = await uploadFromMemory(pictureBytes, uid);

  const success = await admin.firestore().runTransaction(async (transaction) => {
    return updateProfilePicUrl({ transaction: transaction, uid: uid, profilePicUrl: publicUrl });
  });
  return {
    success: success,
    message: success ? "Your profile picture was updated" : "Internal Server Error",
  };
});

async function uploadFromMemory(buffer: Buffer, uid: string): Promise<string> {
  const pictureBucket: Bucket = await getProfilePicBucket();
  const filename = StoragePaths.PROFILE_PIC_FOLDER + uuidv4() + ".jpeg";
  const pictureFile = pictureBucket.file(filename);
  await pictureFile.save(buffer, {
    contentType: "image/jpeg",
  });
  Logger.log({
    logName: "updateProfilePicture", message: `profile pic ${filename} uploaded to ${pictureBucket.name}.`,
    labels: new Map([["expertId", uid]]),
  });
  return pictureFile.publicUrl();
}

