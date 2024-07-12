const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
const admin = require("firebase-admin");

admin.initializeApp();

exports.helloWorld = onRequest((request, response) => {
  logger.info("Hello logs!", {structuredData: true});
  response.send("Hello from Firebase!");
});

exports.onUserCreate = require("./auth_triggers/on_user_create");
exports.onUserDelete = require("./firestore_triggers/on_user_delete");
exports.onUserUpdate = require("./firestore_triggers/on_user_update");
