import * as admin from "firebase-admin";
import { StoragePaths } from "../storage_paths";
export function getDefaultProfilePicUrl(): string {
  const defaultProfilePicName = "Portrait_Placeholder.png";
  const pictureBucket = StoragePaths.BUCKET_URL + StoragePaths.PROFILE_PIC_FOLDER;
  const defaultPicFile = admin.storage()
    .bucket(pictureBucket)
    .file(defaultProfilePicName);

  return defaultPicFile.publicUrl();
}
