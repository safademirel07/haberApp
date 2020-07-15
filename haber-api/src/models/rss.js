const mongoose = require("mongoose")

const rssSchema = new mongoose.Schema({
    site: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'NewsSite',
        required : true,
        unique : true
    },
    category: {
        type: String,
        required : true,
    },
    url: {
        type: String,
        required : true,
    },
})

const RSS = mongoose.model("RSS",rssSchema)

module.exports = RSS