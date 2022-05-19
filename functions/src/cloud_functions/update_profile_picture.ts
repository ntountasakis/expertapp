import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {v4 as uuidv4} from "uuid";

export const updateProfilePicture = functions.https.onCall(
    async (data, context) => {
      if (context.auth == null) {
        throw new Error("Cannot call by unauthorized users");
      }

      const profilePictureBucket = "gs://expert-app-backend.appspot.com";
      const generatedImageName = `profilePics/${uuidv4()}`;
      const pictureBucket = admin.storage().bucket(profilePictureBucket);
      const doesExist = await pictureBucket.exists();
      if (!doesExist) {
        throw new Error(`Bucket: ${profilePictureBucket} does not exist`);
      }

      const pictureBytes : Buffer = Buffer.from(data.pictureBytes);

      const pictureFile = pictureBucket.file(generatedImageName);
      await pictureFile.save(pictureBytes);

      return {url: `${pictureFile.publicUrl()}`};
    });
