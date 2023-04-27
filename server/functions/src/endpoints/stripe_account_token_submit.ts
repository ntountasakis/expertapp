import * as functions from "firebase-functions";
import configureStripeProviderForFunctions from "../stripe/stripe_provider_functions_configurer";
import {StripeProvider} from "../shared/src/stripe/stripe_provider";
import {Logger} from "../shared/src/google_cloud/google_cloud_logger";

export const stripeAccountTokenSubmit = functions.https.onRequest(async (request, response) => {
  await configureStripeProviderForFunctions();
  const uid = request.query.uid;
  const version = request.query.version;
  if (typeof uid !== "string" || typeof version !== "string") {
    Logger.logError({
      logName: "stripeAccountTokenSubmit", message: `Cannot parse uid/version, not instance of string. Type: ${typeof uid} Type version: ${typeof version}. `,
    });
    response.status(400).end();
    return;
  }
  const tokenInvalid = typeof request.query.tokenInvalid === "string";
  const redirectUrl = StripeProvider.getAccountLinkRefreshUrl({hostname: request.hostname, uid: uid, version: version});

  response.set("Content-Type", "text/html");
  // eslint-disable-next-line max-len
  response.send(Buffer.from(accountTokenSubmitHtml(redirectUrl, tokenInvalid)));
  response.status(200).end();
});


function accountTokenSubmitHtml(requestUrl: string, wasTokenInvalid: boolean): string {
  let html = `
    <!DOCTYPE html>
    <html>
        <head>
            <title>Token Validation</title>
            <style>
                body {
                font-family: Arial, sans-serif;
                font-size: 32px;
                }
                div {
                margin: 0 auto;
                width: 80%;
                display: block;
                text-align: center;
                }

                h2 {text-align: center;}
                h3 {text-align: center; color: red}

                input[type="text"] {
                width: 100%;
                padding: 12px 20px;
                margin: 8px 0;
                box-sizing: border-box;
                border: 2px solid #ccc;
                border-radius: 4px;
                font-size: 48px;
                }

                input[type="submit"] {
                width: 50%;
                background-color: #4CAF50;
                color: white;
                padding: 14px 20px;
                margin: 8px 0;
                border: none;
                border-radius: 4px;
                cursor: pointer;
                font-size: 48px;
                }
            </style>
        </head>
        <body>
            <h2>Please enter the token you were given</h2>`;
  if (wasTokenInvalid) {
    html += `
            <h3>Token invalid, try again.</h3>
    `;
  }
  html += `
            <div>
                <label for="token">Enter Token:</label>
                <input type="text" id="token" name="token">
                <input type="submit" value="Submit" onclick="submitToken()">
                <script>
                    function submitToken() {
                    var tokenValue = document.getElementById('token').value;
                    var url = "${requestUrl}&token=" + tokenValue;
                    window.location.replace(url);
                    }
                </script>
            </div>
        </body>
    </html>
`;
  return html;
}
