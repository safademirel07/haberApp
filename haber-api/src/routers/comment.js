const express = require("express")
const router = new express.Router()
const mongoose = require("mongoose")
const News = require("../models/news")
const Comment = require("../models/comment")
var auth = require("../middleware/auth")
const moment = require("moment")
const User = require("../models/user")

router .post("/comment/get", async(req,res) => {
    try {
        const newsID = req.query.news
        const news = await News.findById(newsID)

        if (!news) {
            res.status(400).send({error : "News not found."})
        }

        const comments = await Comment.find({news : newsID})

        var data = []

        for (var comment of comments) {
            var object = comment.toObject()

            delete object["__v"]
    
            object["date"] = moment(comment.date).unix();

            const userOfObject = await User.findById(comment.user)

            if (!userOfObject) {
                res.status(400).send({error : "User not found."})
                continue
            }
    
    
            data.push({...object, "userName" : userOfObject.name, "userPhoto" : userOfObject.profilePhoto})
    
        }

        res.send(data)
    } catch (e) {
        console.log(e)
        res.status(400).send({error : e})

    }
})

router.post("/comment/add", auth.auth, async(req,res) => {

    try {
        const user = req.user
        const newsID = mongoose.Types.ObjectId(req.body.news)
        const comment = req.body.comment

        if (!user) {
            res.status(400).send({error : "User not found."})
            return
        }

        const news = await News.findById(newsID)

        if (!news) {
            res.status(400).send({error : "News not found."})
            return
        }
     
        const userID = user._id

        const date = Date.now();

        const createComment = new Comment({
            user : user._id,
            news : news._id,
            text : comment,
            date : date,
        })

        await createComment.save()

        var object = createComment.toObject()

        delete object["__v"]

        object["date"] = moment(date).unix();


        res.send({...object, "userName" : user.name, "userPhoto" : user.profilePhoto})
        
    } catch (e) {
        console.log("error " + e)
        res.status(400).send({error : e})
    }
})

module.exports = router
