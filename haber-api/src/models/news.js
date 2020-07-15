const mongoose = require("mongoose")

const newsSchema = new mongoose.Schema({
    rss: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'RSS',
        required : true,
    },
    link: {
        type: String,
        required : true,
        unique : true
    },
    title: {
        type: String,
        required : true,
    },
    description: {
        type: String,
        required : true,
    },
    body: {
        type: String,
        required : true,
    },
    date: {
        type: String,
        required : true,
    },
    image: {
        type: String,
        required : true,
    },
})

const News = mongoose.model("News",newsSchema)

module.exports = News