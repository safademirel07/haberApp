const mongoose = require("mongoose")

const newsSiteSchema = new mongoose.Schema({
    url: {
        type: String,
        required : true,
        unique : true
    },
    name: {
        type: String,
        required : true,
    },
    image: {
        type: String,
        required : true,
    },
})

const NewsSite = mongoose.model("NewsSite",newsSiteSchema)

module.exports = NewsSite