import createStripePaymentIntent from "../src/stripe/payment_intent_creator";

test("PaymentIntent should fail: Description too long", async () => {
  const customerId = "cus_M5nT1n5pP6F4aA"; // jan@example.com
  const customerEmail = "jan@example.com";
  const [valid, errorMessage, clientSecret] =
    await createStripePaymentIntent(customerId, customerEmail, 2000, "Call Transaction Initiate", "12345");
  expect(valid).toBe(false);
  expect(errorMessage).not.toBe("");
  expect(clientSecret).toBe("");
});

test("PaymentIntent success", async () => {
  const customerId = "cus_M5nT1n5pP6F4aA"; // jan@example.com
  const customerEmail = "jan@example.com";
  const [valid, errorMessage, paymentIntentId, clientSecret] =
    await createStripePaymentIntent(customerId, customerEmail, 2000, "Call Transaction", "4567");
  expect(valid).toBe(true);
  expect(errorMessage).toBe("");
  expect(paymentIntentId).not.toBe("");
  expect(clientSecret).not.toBe("");
});
