import * as admin from "firebase-admin";

export const sendToken = function(token: string): void {
  const message = {
    data: {
      score: "850",
      time: "2:45",
    },
    token: token,
  };

  // Send a message to the device corresponding to the provided
  // registration token.


  admin.messaging().send(message)
      .then((response: any) => {
        // Response is a message ID string.
        console.log("Successfully sent message:", response);
      })
      .catch((error: any) => {
        console.log("Error sending message:", error);
      });
};
