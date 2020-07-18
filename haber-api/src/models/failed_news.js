const mongoose = require("mongoose")

const failedNewsSchema = new mongoose.Schema({
    url: {
        type: String,
        required : true,
    },
})

const FailedNews = mongoose.model("FailedNews",failedNewsSchema)

module.exports = FailedNews