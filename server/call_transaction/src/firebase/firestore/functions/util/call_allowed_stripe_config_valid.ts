import {PrivateUserInfo} from "../../../../../../functions/src/shared/src/firebase/firestore/models/private_user_info";
import {isStringDefined} from "../../../../../../functions/src/shared/src/general/utils";

export default function callAllowedStripeConfigValid({callerUserInfo, calledUserInfo}:
  {callerUserInfo: PrivateUserInfo, calledUserInfo: PrivateUserInfo}): boolean {
  const callerProperlyConfigured = isStringDefined(callerUserInfo.stripeCustomerId);
  const calledProperlyConfigured = isStringDefined(calledUserInfo.stripeConnectedId);

  if (!callerProperlyConfigured) {
    throw new Error("Caller not properly configured, has no StripeCustomerId");
  }
  if (!calledProperlyConfigured) {
    throw new Error("Called not properly configured, has no StripeConnectedId");
  }
  return callerProperlyConfigured && calledProperlyConfigured;
}
