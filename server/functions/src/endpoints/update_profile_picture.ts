import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {v4 as uuidv4} from "uuid";
import {Bucket} from "@google-cloud/storage";
import {updateProfilePicUrl} from "../shared/src/firebase/firestore/functions/update_profile_pic_url";
import {Logger} from "../shared/src/google_cloud/google_cloud_logger";
import {getProfilePicBucket} from "../shared/src/firebase/storage/functions/get_profile_pic_bucket_ref";
import {StoragePaths} from "../shared/src/firebase/storage/storage_paths";

export const updateProfilePicture = functions.https.onCall(async (data, context) => {
  if (context.auth == null) {
    throw new Error("Cannot call by unauthorized users");
  }
  const uid = context.auth.uid;
  const pictureData = data.pictureBytes;
  const fromSignUpFlow = data.fromSignUpFlow;
  const version = data.version;

  if (pictureData == null || fromSignUpFlow == null || version == null) {
    throw new Error("Cannot updateProfilePicture with missing parameters");
  }

  const pictureBytes: Buffer = Buffer.from(pictureData);
  const publicUrl = await uploadFromMemory(pictureBytes, uid, version);

  const success = await admin.firestore().runTransaction(async (transaction) => {
    return updateProfilePicUrl({transaction: transaction, uid: uid, profilePicUrl: publicUrl,
      fromSignUpFlow: fromSignUpFlow, version: version});
  });
  return {
    success: success,
    message: success ? "Your profile picture was updated" : "Internal Server Error",
  };
});

async function uploadFromMemory(buffer: Buffer, uid: string, version: string): Promise<string> {
  const pictureBucket: Bucket = await getProfilePicBucket();
  const filename = StoragePaths.PROFILE_PIC_FOLDER + uuidv4() + ".jpeg";
  const pictureFile = pictureBucket.file(filename);
  await pictureFile.save(buffer, {
    contentType: "image/jpeg",
  });
  Logger.log({
    logName: "updateProfilePicture", message: `profile pic ${filename} uploaded to ${pictureBucket.name}.`,
    labels: new Map([["expertId", uid], ["version", version]]),
  });
  return pictureFile.publicUrl();
}

