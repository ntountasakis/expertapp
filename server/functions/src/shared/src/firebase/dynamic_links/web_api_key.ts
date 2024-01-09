import axios from "axios";


export class FirebaseDynamicLinkProvider {
  static WEB_API_KEY = "AIzaSyCK6muU1XDxjQL6ftxoQcoYUFjFLktfI7s";
  static DYNAMIC_LINK_URL_PREFIX = "https://globalguide.page.link";
  static DYNAMIC_LINK_ENDPOINT = "https://firebasedynamiclinks.googleapis.com/v1/shortLinks?key=" + FirebaseDynamicLinkProvider.WEB_API_KEY;
  static LINK_TYPE_KEY = "expertLinkType";
  static LINK_TYPE_PROFILE_VALUE = "visitProfile";
  static LINK_TYPE_CALL_NOTIFICATION_VALUE = "callNotification";
  static EXPERT_UID_KEY = "expertUid";
  static CALLER_UID_KEY = "callerUid";
  static CALL_TRANSACTION_ID_KEY = "callTransactionId";
  static CALL_RATE_START_CENTS_KEY = "callRateStartCents";
  static CALL_RATE_PER_MINUTE_CENTS_KEY = "callRatePerMinuteCents";
  static CALL_JOIN_EXPIRATION_TIME_UTC_MS_KEY = "callJoinExpirationTimeUtcMs";


  static async generateDynamicLinkExpertProfile({expertUid}: { expertUid: string }): Promise<string> {
    const response = await axios.post(this.DYNAMIC_LINK_ENDPOINT, {
      "dynamicLinkInfo": {
        "domainUriPrefix": this.DYNAMIC_LINK_URL_PREFIX,
        "link": "https://www.example.com" + "?" +
        this.LINK_TYPE_KEY + "=" + this.LINK_TYPE_PROFILE_VALUE + "&" +
        this.EXPERT_UID_KEY + "=" + expertUid,
        "androidInfo": {
          "androidPackageName": "io.guruportal.globalguide",
        },
        "iosInfo": {
          "iosBundleId": "io.guruportal.globalguide",
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

  static async generateDynamicLinkExpertIncomingCallNotification({expertUid, callerUid, callTransactionId,
    callRateStartCents, callRatePerMinuteCents, callJoinExpirationTimeUtcMs}: {expertUid: string, callerUid: string, callTransactionId: string,
    callRateStartCents: string, callRatePerMinuteCents: string, callJoinExpirationTimeUtcMs: string}): Promise<string> {
    const response = await axios.post(this.DYNAMIC_LINK_ENDPOINT, {
      "dynamicLinkInfo": {
        "domainUriPrefix": this.DYNAMIC_LINK_URL_PREFIX,
        "link": "https://www.example.com" + "?" +
        this.LINK_TYPE_KEY + "=" + this.LINK_TYPE_CALL_NOTIFICATION_VALUE + "&" +
        this.EXPERT_UID_KEY + "=" + expertUid + "&" +
        this.CALLER_UID_KEY + "=" + callerUid + "&" +
        this.CALL_TRANSACTION_ID_KEY + "=" + callTransactionId + "&" +
        this.CALL_RATE_START_CENTS_KEY + "=" + callRateStartCents + "&" +
        this.CALL_RATE_PER_MINUTE_CENTS_KEY + "=" + callRatePerMinuteCents + "&" +
        this.CALL_JOIN_EXPIRATION_TIME_UTC_MS_KEY + "=" + callJoinExpirationTimeUtcMs,
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
