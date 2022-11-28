import {isStringDefined} from "../../../../../../shared/src/general/utils";
import {PrivateUserInfo} from "../../../../../../shared/src/firebase/firestore/models/private_user_info";

export default function callAllowedStripeConfigValid({callerUserInfo, calledUserInfo}:
  {callerUserInfo: PrivateUserInfo, calledUserInfo: PrivateUserInfo}): boolean {
  const callerProperlyConfigured = isStringDefined(callerUserInfo.stripeCustomerId);
  const calledProperlyConfigured = isStringDefined(calledUserInfo.stripeConnectedId);

  if (!callerProperlyConfigured) {
    console.error("Caller not properly configured, has no StripeCustomerId");
  }
  if (!calledProperlyConfigured) {
    console.error("Called not properly configured, has no StripeConnectedId");
  }
  return callerProperlyConfigured && calledProperlyConfigured;
}
