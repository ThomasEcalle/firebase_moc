const functions = require("firebase-functions");
const admin = require("firebase-admin");

module.exports = functions
    .region("europe-west1")
    .auth.user()
    .onCreate(async (user) => {
      const userId = user.uid;
      const creationTime = user.metadata.creationTime;
      const userEmail = user.email;
      const emailVerified = user.emailVerified;
      // eslint-disable-next-line max-len
      const providers = user.providerData.map((provider) => provider.providerId);
      functions.logger.info(`User created: ${JSON.stringify(user)}`);

      return admin.firestore().collection("users").doc(userId).set({
        creationTime: creationTime,
        id: userId,
        email: userEmail,
        emailVerified: emailVerified,
        providers: providers,
      }, {merge: true});
    });
