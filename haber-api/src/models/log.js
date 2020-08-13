const mongoose = require("mongoose")

const logSchema = mongoose.Schema({
    firebaseUID: {
        type: String,
        required : true,
    },
    firebaseMail: {
        type: String,
    },
    isAnonymous : {
        type : Boolean,

    },
    user : {
        type: mongoose.Schema.Types.ObjectId,
        ref: "User"
    },
    os : {
        type : String,
    },
    appVersion : {
        type : String,
    },
    appBuildNumber : {
        type : String,
    },
    deviceManufacturer : {
        type : String,
    },
    deviceModel : {
        type : String,
    },
    deviceProduct : {
        type : String,
    },
    deviceSDK : {
        type : String,
    },
    deviceID : {
        type : String,
    },
    deviceAndroidID : {
        type : String,
    },
    date : {
        type : Date,
        default : Date.now(),
    },
})

const Log = mongoose.model("Log", logSchema)

module.exports = Log