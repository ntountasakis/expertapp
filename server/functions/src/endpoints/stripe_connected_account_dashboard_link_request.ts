import * as functions from "firebase-functions";
import { getPrivateUserDocumentNoTransact } from "../../../shared/src/firebase/firestore/document_fetchers/fetchers";
import { PrivateUserInfo } from "../../../shared/src/firebase/firestore/models/private_user_info";
import createConnectedAccountDashboardLoginLink from "../../../shared/src/stripe/create_connected_account_dashboard_login_link";
import configureStripeProviderForFunctions from "../stripe/stripe_provider_functions_configurer";

export const stripeConnectedAccountDashboardLinkRequest = functions.https.onRequest(async (request, response) => {
    await configureStripeProviderForFunctions();
    const uid = request.query.uid;
    if (typeof uid !== "string") {
        console.log(`Cannot parse uid, not instance of string. Type: ${typeof uid}`);
        response.status(400);
        return;
    }
    const privateUserInfo: PrivateUserInfo = await getPrivateUserDocumentNoTransact({ uid: uid });
    if (!privateUserInfo.stripeConnectedId) {
        console.log(`Uid ${uid} does not have a connected account.`);
        response.status(400);
        return;
    }
    const url = await createConnectedAccountDashboardLoginLink({ connectedAccountId: privateUserInfo.stripeConnectedId });
    console.log(`Generated stripe connected account dashboard link for uid ${uid}: ${url}`);
    response.redirect(url);
});