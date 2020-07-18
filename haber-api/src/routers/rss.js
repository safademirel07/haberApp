const express = require("express")
const router = new express.Router()
const RSS = require('../models/rss')
const NewsSite = require("../models/news_site")
const Category = require("../models/category")

router.get("/rss/get", async (req,res) => {
    const allRSS = await RSS.find({})

    var data = []

    for await (const rss of allRSS) {
        const site = await NewsSite.findOne({"_id" : rss.site})
        const category = await Category.findOne({"_id" : rss.category})
        data.push({rss, site, category})
    }

    res.send(data)

})

router.get("/rss/sites_categories", async (req,res) => {
    const allRSS = await RSS.find({})

    var sites = []
    var categories = []

     for await (const rss of allRSS) {
        site = await NewsSite.findById(rss.site)
        category = rss.category

        if (!sites.includes(site)) {
            sites.push(site)
        }

        console.log(category)
        if (!categories.includes(category)) {
            categories.push(category)
        }

    }


    res.send({ sites, categories})

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


router.post("/rss/category/add", async (req,res) => {

    const category = req.body.name;

    const isExists = await Category.findOne({ name : category.toLowerCase()})
    if (isExists)
    {
        res.status(400).send({error : "This category is already exists."})
        return
    }

    const newCategory = new Category({...req.body})

    try {
        await newCategory.save()
        res.status(201). send(newCategory)
    } catch(e) {
        console.log("error ne " +e )
        res.status(400).send(e)
    }
})


module.exports = router