import * as admin from "firebase-admin";
import {Bucket} from "@google-cloud/storage";
import { StoragePaths } from "../storage_paths";
export async function getProfilePicBucket(): Promise<Bucket> {
  // const profilePictureBucket = StoragePaths.STORAGE_URL + StoragePaths.PROFILE_PIC_BUCKET;
  const profilePictureBucket = StoragePaths.PROFILE_PIC_BUCKET;
  const pictureBucket: Bucket = admin.storage().bucket(profilePictureBucket);
  const doesExist = await pictureBucket.exists();
  if (!doesExist) {
    throw new Error(`Bucket: ${profilePictureBucket} does not exist`);
  }
  return pictureBucket;
}
