import * as functions from "firebase-functions";
import {getPrivateUserDocumentNoTransact} from "../shared/src/firebase/firestore/document_fetchers/fetchers";
import {checkTokenValidAndRemove} from "../shared/src/firebase/firestore/functions/check_token_valid_and_remove";
import {updateConnectedAccountPrivateUserInfo} from "../shared/src/firebase/firestore/functions/update_connected_account_private_user_info";
import {PrivateUserInfo} from "../shared/src/firebase/firestore/models/private_user_info";
import {StripeProvider} from "../shared/src/stripe/stripe_provider";
import {createAccountLinkOnboarding} from "../shared/src/stripe/util";
import configureStripeProviderForFunctions from "../stripe/stripe_provider_functions_configurer";
import {Logger} from "../shared/src/google_cloud/google_cloud_logger";

export const stripeAccountLinkRefresh = functions.https.onRequest(async (request, response) => {
  await configureStripeProviderForFunctions();
  const uid = request.query.uid;
  const version = request.query.version;
  if (typeof uid !== "string" || typeof version !== "string") {
    Logger.logError({
      logName: "stripeAccountLinkRefresh", message: `Cannot parse uid/version, not instance of string. Type uid: ${typeof uid} \
      Type version: ${typeof version}. Request: ${JSON.stringify(request.query)}`,
    });
    response.status(400);
    return;
  }
  const privateUserInfo: PrivateUserInfo = await getPrivateUserDocumentNoTransact({uid: uid});
  if (privateUserInfo.stripeConnectedId) {
    await redirectToStripeAccountLink({connectedAccountId: privateUserInfo.stripeConnectedId, hostname: request.hostname, uid: uid, response: response,
      version: version});
    return;
  }
  const userProvidedToken = (typeof request.query.token === "string" && request.query.token.length > 0);
  if (userProvidedToken) {
    const tokenValid = await checkTokenValidAndRemove({token: request.query.token as string});
    if (tokenValid) {
      const stripeConnectedId: string = await updateConnectedAccountPrivateUserInfo({
        uid: uid, privateUserInfo: privateUserInfo,
      });
      await redirectToStripeAccountLink({connectedAccountId: stripeConnectedId, hostname: request.hostname, uid: uid, response: response,
        version: version});
    } else {
      response.redirect(StripeProvider.getAccountTokenSubmitUrl({hostname: request.hostname, uid: uid, tokenInvalid: true, version: version}));
    }
  } else {
    response.redirect(StripeProvider.getAccountTokenSubmitUrl({hostname: request.hostname, uid: uid, tokenInvalid: false, version: version}));
  }
});

async function redirectToStripeAccountLink({connectedAccountId, hostname, uid, version, response}: {
  connectedAccountId: string, hostname: string, uid: string, response: functions.Response, version: string,
}) {
  const accountLink = await createAccountLinkOnboarding({
    stripe: StripeProvider.STRIPE, stripeConnectedId: connectedAccountId,
    refreshUrl: StripeProvider.getAccountLinkRefreshUrl({hostname: hostname, uid: uid, version: version}),
    returnUrl: StripeProvider.getAccountLinkReturnUrl({hostname: hostname, uid: uid, version: version}),
    functionContext: "stripeAccountLinkRefresh",
    expertUid: uid,
  });
  response.redirect(accountLink);
}
