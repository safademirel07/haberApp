const mongoose = require("mongoose")

const rssSchema = new mongoose.Schema({
    site: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'NewsSite',
        required : true,
    },
    category: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Category',
        required : true,
    },
    url: {
        type: String,
        required : true,
        unique : true
    },
})

const RSS = mongoose.model("RSS",rssSchema)

module.exports = RSS