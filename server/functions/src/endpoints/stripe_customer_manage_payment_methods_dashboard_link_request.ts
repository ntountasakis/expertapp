import * as functions from "firebase-functions";
import {getPrivateUserDocumentNoTransact} from "../../../shared/src/firebase/firestore/document_fetchers/fetchers";
import {PrivateUserInfo} from "../../../shared/src/firebase/firestore/models/private_user_info";
import createCustomerManagePaymentMethodsDashboardLoginLink from "../../../shared/src/stripe/create_customer_manage_payment_methods_dashboard_login_link";

export const stripeManagePaymentMethodsLinkRequest = functions.https.onRequest(async (request, response) => {
  const uid = request.query.uid;
  if (typeof uid !== "string") {
    console.log(`Cannot parse uid, not instance of string. Type: ${typeof uid}`);
    response.status(400);
    return;
  }
  const privateUserInfo: PrivateUserInfo = await getPrivateUserDocumentNoTransact({uid: uid});
  if (!privateUserInfo.stripeCustomerId) {
    console.log(`Uid ${uid} does not have a stripe customer account.`);
    response.status(400);
    return;
  }
  const url = await createCustomerManagePaymentMethodsDashboardLoginLink({customerAccountId: privateUserInfo.stripeCustomerId});
  console.log(`Generated stripe customer manage payment methods dashboard link for uid ${uid}: ${url}`);
  response.redirect(url);
});
