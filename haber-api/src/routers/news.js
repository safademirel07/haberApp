const express = require("express")
const router = new express.Router()
const News = require("../models/news")
const RSS = require("../models/rss")
const NewsSite = require("../models/news_site")

router.get("/news/get", async (req,res) => {
    const allNews = await News.find({})

    const data = []

    for (const news of allNews)
    {   

        data.push(await news.toJSON())
    
    }
    res.send(data)

})


module.exports = router