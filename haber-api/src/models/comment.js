const mongoose = require("mongoose")
const User = require("./User")
const News = require("./News")

const commentSchema = mongoose.Schema({
    user : {
        type: mongoose.Schema.Types.ObjectId,
        ref: User
    },
    news : {
        type: mongoose.Schema.Types.ObjectId,
        ref: News
    },
    text : {
        type : String,
        text: true,
        required: true,
    }

})

const Comment = mongoose.model("Comment", commentSchema)

module.exports = Comment