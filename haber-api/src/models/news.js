const mongoose = require("mongoose")

const newsSchema = new mongoose.Schema({
    link: {
        type: String,
        required : true,
        unique : true
    },
    title: {
        type: String,
        required : true,
        unique : true
    },
    description: {
        type: String,
        required : true,
        unique : true
    },
    body: {
        type: String,
        required : true,
        unique : true
    },
    date: {
        type: String,
        required : true,
        unique : true
    },
    image: {
        type: String,
        required : true,
        unique : true
    },
})

const News = mongoose.model("News",newsSchema)

module.exports = News