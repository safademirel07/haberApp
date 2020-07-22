var firebaseAdmin = require("firebase-admin");
var serviceAccount = require("./serviceAccountKey.json");

firebaseAdmin.initializeApp({
    credential: firebaseAdmin.credential.cert(serviceAccount),
    databaseURL: "https://haberapp-54a0c.firebaseio.com"
  });


module.exports = firebaseAdmin