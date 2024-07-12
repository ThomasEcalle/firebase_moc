const functions = require("firebase-functions");
const admin = require("firebase-admin");

module.exports = functions
    .firestore
    .document(`users/{id}`)
    .onUpdate(async (snapshot) => {
      const before = snapshot.before.data();
      const after = snapshot.after.data();

      const beforeSwitch = before.switch || false;
      const afterSwitch = after.switch || false;

      functions.logger.info(`Before switch: ${beforeSwitch} & after switch: ${afterSwitch}`);

      functions.logger.info("Sending notification");

      await admin.messaging().send({
        notification: {
          title: "Salut à toi",
          body: "Voici une notification",
        },
        token: after.notificationToken,
      });
    });
