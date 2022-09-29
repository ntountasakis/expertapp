import * as functions from "firebase-functions";

export const stripeAccountLinkReturn = functions.https.onRequest(async (request, response) => {
  const account = request.query.account;
  if (typeof account !== "string") {
    console.log("Cannot parse account, not instance of string");
    response.status(400);
    return;
  }

  console.log(`Handling account link return for account ${account}`);
  response.status(200);
});
