
import * as functions from "firebase-functions";
import {StripeProvider} from "../../../shared/src/stripe/stripe_provider";

export const stripeAccountTokenSubmit = functions.https.onRequest(async (request, response) => {
  const uid = request.query.uid;
  if (typeof uid !== "string") {
    console.log("Cannot parse uid, not instance of string");
    response.status(400).end();
    return;
  }

  const redirectUrl = StripeProvider.getAccountLinkRefreshUrl({hostname: request.hostname, uid: uid});
  console.log(`On token submit button will make a request to ${redirectUrl}`);

  response.set("Content-Type", "text/html");
  // eslint-disable-next-line max-len
  response.send(Buffer.from(accountTokenSubmitHtml(redirectUrl)));
  response.status(200).end();
});


function accountTokenSubmitHtml(requestUrl: string): string {
  const html = `
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
            <h2>Please provide the token you were given:</h2>
            <div>
                <label for="token">Enter Token:</label>
                <input type="text" id="token" name="token">
                <input type="submit" value="Submit" onclick="submitToken()">
                <script>
                    function submitToken() {
                    var url = "${requestUrl}&token=" + token;
                    window.location.replace(url);
                    }
                </script>
            </div>
        </body>
    </html>
`;
  return html;
}
