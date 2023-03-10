import * as functions from "firebase-functions";
import { StripeProvider } from "../../../shared/src/stripe/stripe_provider";
import { createAccountLinkOnboarding, retrieveAccount } from "../../../shared/src/stripe/util";
import { getPrivateUserDocumentNoTransact } from "../../../shared/src/firebase/firestore/document_fetchers/fetchers";
import { PrivateUserInfo } from "../../../shared/src/firebase/firestore/models/private_user_info";
import { createExpertUser } from "../../../shared/src/firebase/firestore/functions/create_expert_user";

export const stripeAccountLinkReturn = functions.https.onRequest(async (request, response) => {
  const uid = request.query.uid;
  if (typeof uid !== "string") {
    console.log("Cannot parse uid, not instance of string");
    response.status(400).end();
    return;
  }

  console.log(`Handling account link return for account ${uid}`);
  const privateUserInfo: PrivateUserInfo = await getPrivateUserDocumentNoTransact({ uid: uid });
  const account = await retrieveAccount({ stripe: StripeProvider.STRIPE, account: privateUserInfo.stripeConnectedId });

  if (!account.payouts_enabled || !account.details_submitted) {
    let messagePrefix = `Connected account: ${uid} still needs `;
    if (account.payouts_enabled) {
      messagePrefix += " to enable payouts ";
    }
    if (account.details_submitted) {
      messagePrefix += " to finish submitting details ";
    }
    console.warn(messagePrefix);
    const accountLink = await createAccountLinkOnboarding({
      stripe: StripeProvider.STRIPE, account: uid,
      refreshUrl: StripeProvider.getAccountLinkRefreshUrl({ hostname: request.hostname, uid: uid }),
      returnUrl: StripeProvider.getAccountLinkReturnUrl({ hostname: request.hostname, uid: uid })
    });
    response.redirect(accountLink);
  } else {
    await createExpertUser(({
      uid: uid, profileDescription: "", profilePicUrl: "https://storage.googleapis.com/expert-app-backend.appspot.com/profilePics/Portrait_Placeholder.png",
    }));
    console.log(`Connected account: ${uid} sign up process complete`);

    response.set("Content-Type", "text/html");
    // eslint-disable-next-line max-len
    response.send(Buffer.from(accountCreateSuccessHtml()));
    response.status(200).end();
  }
});


function accountCreateSuccessHtml(): string {
  const html = `
  <!DOCTYPE html>
  <html>
  <head>
    <title>Sign Up Success</title>
    <style>
      body {
        font-family: Arial, sans-serif;
        text-align: center;
        padding: 100px;
        font-size: 32px;
      }

      h1 {
        color: green;
      }

      img {
        width: 50%;
      }
    </style>
  </head>
  <body>
    <h1>You have successfully signed up!</h1>
    <img src="https://storage.googleapis.com/expert-app-backend.appspot.com/appImages/confetti.jpg" alt="Confetti">
    <p>You may now return to the main menu.</p>
  </body>
  </html>
`;
  return html;
}
