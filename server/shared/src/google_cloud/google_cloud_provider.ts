export class GoogleCloudProvider {
    static PROJECT = "expert-app-backend";
    static STRIPE_PRIVATE_KEY_PREFIX = "projects/" + GoogleCloudProvider.PROJECT + "/secrets/stripe-private-key/versions/";
}