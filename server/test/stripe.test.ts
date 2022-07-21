import Stripe from "stripe";
// eslint-disable-next-line max-len
const stripe = new Stripe("sk_test_51LLQIdAoQ8pfRhfFWhXXPMmQkBMR1wAZSiFAc0fRZ3OQfnVJ3Mo5MXt65rv33lt0A7mzUIRWahIbSt2iFDFDrZ6C00jF2hT9eZ", {
  apiVersion: "2020-08-27",
});

test("create customers", () => {
  stripe.customers.create({
    email: "customer@example.com",
  })
      .then((customer) => console.log(customer.id))
      .catch((error) => console.error(error));
});

test("setup intent for customer", async () => {
  const customerId = "cus_M5nT1n5pP6F4aA"; // jan@example.com
  const paymentMethodId = "foo";
  const setupIntent = await stripe.setupIntents.create({
    payment_method_types: ["card"],
    confirm: true,
    customer: customerId,
    usage: "off_session",
    flow_directions: ["inbound"],
    payment_method: paymentMethodId,
  });

  console.log(setupIntent);
});
