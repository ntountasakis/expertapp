import * as admin from "firebase-admin";
import { StoragePaths } from "../storage_paths";
export function getDefaultProfilePicUrl(): string {
  const defaultProfilePicName = "Portrait_Placeholder.png";
  const pictureBucket = StoragePaths.STORAGE_URL + StoragePaths.PROFILE_PIC_BUCKET;
  const defaultPicFile = admin.storage()
      .bucket(pictureBucket)
      .file(defaultProfilePicName);

  return defaultPicFile.publicUrl();
}
