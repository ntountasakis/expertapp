import axios from "axios";


export class FirebaseDynamicLinkProvider {
  static WEB_API_KEY = "AIzaSyCK6muU1XDxjQL6ftxoQcoYUFjFLktfI7s";
  static DYNAMIC_LINK_URL_PREFIX = "https://expertprofile.page.link";
  static DYNAMIC_LINK_ENDPOINT = "https://firebasedynamiclinks.googleapis.com/v1/shortLinks?key=" + FirebaseDynamicLinkProvider.WEB_API_KEY;
  static EXPERT_UID_KEY = "expertProfile";

  static async generateDynamicLinkExpertProfile({expertUid}: { expertUid: string }): Promise<string> {
    const response = await axios.post(this.DYNAMIC_LINK_ENDPOINT, {
      "dynamicLinkInfo": {
        "domainUriPrefix": this.DYNAMIC_LINK_URL_PREFIX,
        "link": "https://www.example.com" + "?" + this.EXPERT_UID_KEY + "=" + expertUid,
        "androidInfo": {
          "androidPackageName": "com.example.expertapp",
        },
        "iosInfo": {
          "iosBundleId": "com.example.expertapp",
        },
      },
      "suffix": {
        option: "SHORT",
      },
    });

    if (response.status !== 200) {
      throw new Error("Dynamic link generation failed");
    }

    return response.data.shortLink;
  }
}
