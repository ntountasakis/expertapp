import createStripePaymentIntent from "../src/stripe/payment_intent_creator";

test("PaymentIntent should fail: Description too long", async () => {
  const customerId = "cus_M5nT1n5pP6F4aA"; // jan@example.com
  const customerEmail = "jan@example.com";
  const [valid, errorMessage, clientSecret] =
    await createStripePaymentIntent(customerId, customerEmail, 2000, "Call Transaction Initiate");
  expect(valid).toBe(false);
  expect(errorMessage).not.toBe("");
  expect(clientSecret).toBe("");
});
