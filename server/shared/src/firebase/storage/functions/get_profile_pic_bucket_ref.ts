import * as admin from "firebase-admin";
import { Bucket } from "@google-cloud/storage";
import { StoragePaths } from "../storage_paths";
export async function getProfilePicBucket(): Promise<Bucket> {
  const pictureBucket: Bucket = admin.storage().bucket(StoragePaths.BUCKET_URL);
  const doesExist = await pictureBucket.exists();
  if (!doesExist) {
    throw new Error(`Bucket: ${StoragePaths.BUCKET_URL} does not exist`);
  }
  return pictureBucket;
}
