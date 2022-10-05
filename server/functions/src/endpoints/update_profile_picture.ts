import * as functions from "firebase-functions";
import {Bucket} from "@google-cloud/storage";
import {generateProfilePicName} from "../../../shared/firebase/storage/functions/generate_profile_pic_name";
import {getProfilePicBucket} from "../../../shared/firebase/storage/functions/get_profile_pic_bucket_ref";

export const updateProfilePicture = functions.https.onCall(
    async (data, context) => {
      if (context.auth == null) {
        throw new Error("Cannot call by unauthorized users");
      }
      const pictureBucket: Bucket = await getProfilePicBucket();
      const pictureBytes : Buffer = Buffer.from(data.pictureBytes);
      const pictureFile = pictureBucket.file(generateProfilePicName());
      await pictureFile.save(pictureBytes);

      return {url: `${pictureFile.publicUrl()}`};
    });
