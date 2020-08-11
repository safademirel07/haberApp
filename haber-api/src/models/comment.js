const mongoose = require("mongoose")

const commentSchema = mongoose.Schema({
    user : {
        type: mongoose.Schema.Types.ObjectId,
        ref: "User"
    },
    news : {
        type: mongoose.Schema.Types.ObjectId,
        ref: "News"
    },
    text : {
        type : String,
        text: true,
        required: true,
    },
    date : {
        type : Date,
        default : Date.now(),
    }

})

const Comment = mongoose.model("Comment", commentSchema)

module.exports = Comment