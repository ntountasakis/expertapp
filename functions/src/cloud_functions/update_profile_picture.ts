import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {v4 as uuidv4} from "uuid";

export const updateProfilePicture = functions.https.onCall(
    async (data, context) => {
      if (context.auth == null) {
        throw new Error("Cannot call by unauthorized users");
      }

      const profilePictureBucket = "gs://expert-app-backend.appspot.com/profilePics";
      const generatedImageName = uuidv4();
      const newPictureFile = admin.storage().bucket(profilePictureBucket)
          .file(generatedImageName);

      const pictureBytes : Buffer = Buffer.from(data.pictureBytes);
      await newPictureFile.save(pictureBytes);

      console.log(`Uploaded profilePic ${generatedImageName} 
    for user ${context.auth.uid}`);

      return newPictureFile.publicUrl;
    });
