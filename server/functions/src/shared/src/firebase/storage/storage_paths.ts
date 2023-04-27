import {GoogleCloudProvider} from "../../google_cloud/google_cloud_provider";

export class StoragePaths {
  static BUCKET_URL = "gs://expert-app-backend.appspot.com/";
  static PROFILE_PIC_FOLDER = "profilePics/";
  static STORAGE_URL = "https://storage.googleapis.com/" + GoogleCloudProvider.PROJECT + ".appspot.com/";
  static DEFAULT_PROFILE_PIC_URL = StoragePaths.STORAGE_URL + "profilePics/Portrait_Placeholder.png";
  static CONFETTI_PIC_URL = StoragePaths.STORAGE_URL + "appImages/confetti.jpg";
}
