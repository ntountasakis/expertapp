import * as functions from "firebase-functions";
import {getPrivateUserDocumentNoTransact} from "../../../shared/src/firebase/firestore/document_fetchers/fetchers";
import {PrivateUserInfo} from "../../../shared/src/firebase/firestore/models/private_user_info";
import {Logger} from "../../../shared/src/google_cloud/google_cloud_logger";
import createCustomerManagePaymentMethodsDashboardLoginLink from "../../../shared/src/stripe/create_customer_manage_payment_methods_dashboard_login_link";
import configureStripeProviderForFunctions from "../stripe/stripe_provider_functions_configurer";

export const stripeManagePaymentMethodsLinkRequest = functions.https.onRequest(async (request, response) => {
  await configureStripeProviderForFunctions();
  const uid = request.query.uid;
  const version = request.query.version;
  if (typeof uid !== "string" || typeof version !== "string") {
    Logger.logError({
      logName: "stripeManagePaymentMethodsLinkRequest", message: `Cannot parse uid/version, \
      not instance of string. Type uid: ${typeof uid} Type version: ${typeof version}`,
    });
    response.status(400);
    return;
  }
  const privateUserInfo: PrivateUserInfo = await getPrivateUserDocumentNoTransact({uid: uid});
  if (privateUserInfo.stripeCustomerId === undefined || privateUserInfo.stripeCustomerId === "") {
    Logger.logError({
      logName: "stripeManagePaymentMethodsLinkRequest", message: `Uid ${uid} does not have a stripe customer account.`,
      labels: new Map([["userId", uid], ["version", version]]),
    });
    response.status(400);
    return;
  }
  const url = await createCustomerManagePaymentMethodsDashboardLoginLink({customerAccountId: privateUserInfo.stripeCustomerId});
  await Logger.log({
    logName: "stripeManagePaymentMethodsLinkRequest", message: `Generated stripe customer manage payment methods dashboard link for uid ${uid}: ${url}`,
    labels: new Map([["userId", uid], ["version", version]]),
  });
  response.redirect(url);
});
