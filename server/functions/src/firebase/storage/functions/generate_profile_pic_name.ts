import {v4 as uuidv4} from "uuid";
import {StoragePaths} from "../../../../../shared/firebase/storage/storage_paths";
export function generateProfilePicName(): string {
  return `${StoragePaths.PROFILE_PIC_BUCKET}/${uuidv4()}`;
}
