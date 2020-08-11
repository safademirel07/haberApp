const express = require("express")
const router = new express.Router()

var auth = require("../middleware/auth")
const News = require("../models/News")
const Comment = require("../models/comment")


router.post("/comment/add", auth.auth, async(req,res) => {

    try {
        const user = req.user
        const newsID = mongoose.Types.ObjectId(req.query.news)
        const comment = req.query.comment

        if (!user) {
            res.status(400).send({error : "User not found."})
            return
        }

        const news = await News.findById(newsID)

        if (!news) {
            res.status(400).send({error : "News not found."})
        }
     
        const userID = user._id

        const createComment = new Comment({
            user : user._id,
            news : news._id,
            text : comment
        })

        await createComment.save()

        const fullComment = createComment.populate("user")

        res.send(fullComment)
        
    } catch (e) {
        console.log("error " + e)
        res.status(400).send({error : e})
    }
})

module.exports = router
