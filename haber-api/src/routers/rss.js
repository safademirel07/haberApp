const express = require("express")
const router = new express.Router()
const RSS = require('../models/rss')
const NewsSite = require("../models/news_site")

router.get("/rss/get", async (req,res) => {
    const allRSS = await RSS.find({})
    res.send(allRSS)

})

router.post("/rss/create", async (req,res) => {

    const newsSiteID = req.body.site;

    const newsSite = await NewsSite.findById(newsSiteID);

    if (!newsSite)
    {
        res.status(400).send({error : "This News Site doesn't exists."})
        return
    }

    const rss = new RSS({...req.body})

    try {
        await rss.save()
        res.status(201). send(rss)
    } catch(e) {
        console.log("error ne " +e )
        res.status(400).send(e)
    }
})

module.exports = router