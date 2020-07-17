const express = require("express")
const router = new express.Router()

const NewsSite = require('../models/news_site')

router.get("/news_site/all", async (req,res) => {
    const allNewsSites = await NewsSite.find({})
    res.send(allNewsSites)
})

router.post("/news_site/create", async (req,res) => {

    const newsSite = new NewsSite({...req.body})

    try {
        await newsSite.save()
        res.status(201). send(newsSite)
    } catch(e) {
        res.status(400).send(e)
    }
})

module.exports = router