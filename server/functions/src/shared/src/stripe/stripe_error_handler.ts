import stripe from "stripe";
import {Logger} from "../google_cloud/google_cloud_logger";

export default function handleStripeError(functionName: string, error: unknown): string {
  let errorMsg = `Unhandled Error Type ${error}`;
  if (error instanceof stripe.errors.StripeAPIError) {
    errorMsg = `Api Error. Code: ${error.code} Message: ${error.message} Param: ${error.param}`;
  } else if (error instanceof stripe.errors.StripeInvalidRequestError) {
    errorMsg = `Invalid Request Error. Code: ${error.code} Message: ${error.message} Param: ${error.param}`;
  } else if (error instanceof stripe.errors.StripeCardError) {
    errorMsg = `Card Error. Code: ${error.code} Message: ${error.message} Param: ${error.param}`;
  } else if (error instanceof stripe.errors.StripeIdempotencyError) {
    errorMsg = `Idempotency Error. Code: ${error.code} Message: ${error.message} Param: ${error.param}`;
  }
  Logger.logError({
    logName: functionName, message: `Error: ${errorMsg} `,
  });
  return errorMsg;
}
