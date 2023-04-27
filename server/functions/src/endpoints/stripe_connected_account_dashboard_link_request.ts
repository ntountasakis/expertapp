import * as functions from "firebase-functions";
import configureStripeProviderForFunctions from "../stripe/stripe_provider_functions_configurer";
import {getPrivateUserDocumentNoTransact} from "../shared/src/firebase/firestore/document_fetchers/fetchers";
import {PrivateUserInfo} from "../shared/src/firebase/firestore/models/private_user_info";
import createConnectedAccountDashboardLoginLink from "../shared/src/stripe/create_connected_account_dashboard_login_link";
import {Logger} from "../shared/src/google_cloud/google_cloud_logger";

export const stripeConnectedAccountDashboardLinkRequest = functions.https.onRequest(async (request, response) => {
  await configureStripeProviderForFunctions();
  const uid = request.query.uid;
  const version = request.query.version;
  if (typeof uid !== "string" || typeof version !== "string") {
    Logger.logError({
      logName: "stripeConnectedAccountDashboardLinkRequest", message: `Cannot parse uid/version, \
      not instance of string. Type uid: ${typeof uid} Type version: ${typeof version}`,
    });
    response.status(400);
    return;
  }
  const privateUserInfo: PrivateUserInfo = await getPrivateUserDocumentNoTransact({uid: uid});
  if (!privateUserInfo.stripeConnectedId) {
    Logger.logError({
      logName: "stripeConnectedAccountDashboardLinkRequest", message: `Uid ${uid} does not have a connected account.`,
      labels: new Map([["userId", uid], ["version", version]]),
    });
    response.status(400);
    return;
  }
  const url = await createConnectedAccountDashboardLoginLink({connectedAccountId: privateUserInfo.stripeConnectedId});
  Logger.log({
    logName: "stripeConnectedAccountDashboardLinkRequest", message: `Generated stripe connected account dashboard link for uid ${uid}: ${url}`,
    labels: new Map([["expertId", uid], ["version", version]]),
  });
  response.redirect(url);
});
