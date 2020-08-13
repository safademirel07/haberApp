const express = require("express")
const router = new express.Router()
const mongoose = require("mongoose")
const News = require("../models/news")
const Comment = require("../models/comment")
var auth = require("../middleware/auth")
const moment = require("moment")
const User = require("../models/user")

router.get("/comment/get", auth.auth_test,  async(req,res) => {
    try {

        let limit = 5; 
        let page = (Math.abs(req.query.page) || 1) - 1;
    
        const user = req.user

        const newsID = req.query.news
        const news = await News.findById(newsID)

        if (!news) {
            res.status(400).send({error : "News not found."})
        }

        const comments = await Comment.find({news : newsID, active : true}).sort({date : -1}).limit(limit).skip(limit * page)

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

            var isOwner = false

            if (user !=undefined && (user._id.toString() === userOfObject._id.toString())) {
                isOwner = true
            }
    
    
            data.push({...object, isOwner, "userName" : userOfObject.name, "userPhoto" : userOfObject.profilePhoto})
    
        }

        res.send(data)
    } catch (e) {
        console.log(e)
        res.status(400).send({error : e})

    }
})

router.post("/comment/delete", auth.auth, async(req,res) => {
    try {

        const user = req.user
        const commentID = mongoose.Types.ObjectId(req.query.comment)

        if (!user) {
            res.status(400).send({error : "User not found."})
            return
        }
        
        var comment = await Comment.findById(commentID)

        if (!comment) {
            res.status(400).send({error : "Comment not found."})
            return
        }
        
        if (comment.user.toString() != user._id.toString()) {
            res.status(400).send({error : "User ids not matching."})
            return
        }

        comment.active = false
        await comment.save()

        res.send(comment)
        
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

        var isOwner = true


        object["date"] = moment(date).unix();


        res.send({...object, isOwner, "userName" : user.name, "userPhoto" : user.profilePhoto})
        
    } catch (e) {
        console.log("error " + e)
        res.status(400).send({error : e})
    }
})

module.exports = router
