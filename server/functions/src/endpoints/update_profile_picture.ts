import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {v4 as uuidv4} from "uuid";
import {Bucket} from "@google-cloud/storage";
import {getProfilePicBucket} from "../../../shared/src/firebase/storage/functions/get_profile_pic_bucket_ref";
import {updateProfilePicUrl} from "../../../shared/src/firebase/firestore/functions/update_profile_pic_url";

export const updateProfilePicture = functions.https.onCall(async (data, context) => {
  if (context.auth == null) {
    throw new Error("Cannot call by unauthorized users");
  }
  const uid = context.auth.uid;
  const pictureBytes : Buffer = Buffer.from(data.pictureBytes);
  const publicUrl = await uploadFromMemory(pictureBytes);

  await admin.firestore().runTransaction(async (transaction) => {
    updateProfilePicUrl({transaction: transaction, uid: uid, profilePicUrl: publicUrl});
  });
});

async function uploadFromMemory(buffer: Buffer): Promise<string> {
  const pictureBucket: Bucket = await getProfilePicBucket();
  const filename = uuidv4() +".jpeg";
  const pictureFile = pictureBucket.file(filename);
  await pictureFile.save(buffer, {
    contentType: "image/jpeg",
  });
  console.log(`profile pic ${filename} uploaded to ${pictureBucket.name}.`);
  return pictureFile.publicUrl();
}

