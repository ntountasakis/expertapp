import * as functions from "firebase-functions";
import {StripeProvider} from "../../../shared/src/stripe/stripe_provider";
import {createAccountLinkOnboarding} from "../../../shared/src/stripe/util";
import {updateConnectedAccountPrivateUserInfo} from "../../../shared/src/firebase/firestore/functions/update_connected_account_private_user_info";
import {PrivateUserInfo} from "../../../shared/src/firebase/firestore/models/private_user_info";
import {getPrivateUserDocumentNoTransact, getPublicExpertInfoNoTransact} from "../../../shared/src/firebase/firestore/document_fetchers/fetchers";
import {checkTokenValidAndRemove} from "../../../shared/src/firebase/firestore/functions/check_token_valid_and_remove";
import {PublicExpertInfo} from "../../../shared/src/firebase/firestore/models/public_expert_info";

export const stripeAccountLinkRefresh = functions.https.onRequest(async (request, response) => {
  const uid = request.query.uid;
  if (typeof uid !== "string") {
    console.log(`Cannot parse uid, not instance of string. Type: ${typeof uid}`);
    response.status(400);
    return;
  }
  const privateUserInfo: PrivateUserInfo = await getPrivateUserDocumentNoTransact({uid: uid});
  if (privateUserInfo.stripeConnectedId) {
    await redirectToStripeAccountLink({connectedAccountId: privateUserInfo.stripeConnectedId, hostname: request.hostname, uid: uid, response: response});
    return;
  }
  const publicExpertInfo: PublicExpertInfo = await getPublicExpertInfoNoTransact({uid: uid});

  const userProvidedToken = (typeof request.query.token === "string" && request.query.token.length > 0);
  if (userProvidedToken) {
    const tokenValid = await checkTokenValidAndRemove({token: request.query.token as string});
    if (tokenValid) {
      const stripeConnectedId: string = await updateConnectedAccountPrivateUserInfo({
        uid: uid, publicExpertInfo: publicExpertInfo, privateUserInfo: privateUserInfo});
      await redirectToStripeAccountLink({connectedAccountId: stripeConnectedId, hostname: request.hostname, uid: uid, response: response});
      return;
    } else {
      response.redirect(StripeProvider.getAccountTokenSubmitUrl({hostname: request.hostname, uid: uid, tokenInvalid: true}));
    }
  } else {
    response.redirect(StripeProvider.getAccountTokenSubmitUrl({hostname: request.hostname, uid: uid, tokenInvalid: false}));
  }
});

async function redirectToStripeAccountLink({connectedAccountId, hostname, uid, response}: {
  connectedAccountId: string, hostname: string, uid: string, response: functions.Response}) {
  const accountLink = await createAccountLinkOnboarding({stripe: StripeProvider.STRIPE, account: connectedAccountId,
    refreshUrl: StripeProvider.getAccountLinkRefreshUrl({hostname: hostname, uid: uid}),
    returnUrl: StripeProvider.getAccountLinkReturnUrl({hostname: hostname, uid: uid}),
  });
  response.redirect(accountLink);
}
