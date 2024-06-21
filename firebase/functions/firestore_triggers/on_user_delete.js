const functions = require("firebase-functions");
const admin = require("firebase-admin");

module.exports = functions
    .firestore
    .document(`users/{id}`)
    .onDelete(async (snapshot) => {
      functions.logger.info(`User deleted: ${JSON.stringify(snapshot)}`);
      return admin.auth().deleteUser(snapshot.id);
    });
