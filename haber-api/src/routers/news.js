const express = require("express")
const router = new express.Router()
const News = require("../models/news")
const RSS = require("../models/rss")
const NewsSite = require("../models/news_site")
const mongoose = require("mongoose")

// @route    GET news/get?news_sites=(id1,id2)&categories=(id1,id2)&searchWord=xyz&page=1
// @desc     Gets news specified News Sites, Categories, Search Word with pagination.
// to-do     Implement sort with date.
router.get("/news/get", async (req,res) => {

    let limit = 10; //news per page


    const newsSites = req.query.news_sites
    const categories = req.query.categories
    const searchWord = req.query.search
    let page = (Math.abs(req.query.page) || 1) - 1;

    console.log("search" + searchWord)


    console.log(newsSites)

    var filterSites = []
    var filterCategories = []

    if (newsSites != undefined && newsSites.length > 0) {
        var splitNewsSites = newsSites.split(',')
        splitNewsSites.forEach(newsSite => {
            filterSites.push(mongoose.Types.ObjectId(newsSite))
        });
    }
    if (categories != undefined && categories.length > 0) {
        console.log("bu")
        var splitCategories = categories.split(',')
        splitCategories.forEach(category => {
            filterCategories.push(mongoose.Types.ObjectId(category))
        });
    }
    console.log("filterSites" + filterSites)
    console.log("filterCategories" + filterCategories)


    var aggregateQuery =  [
        { "$lookup": {
            "let": { "rssObjID": { "$toObjectId": "$rss" } },
            "from": "rsses",
            "pipeline": [
              { "$match": { "$expr": { "$eq": [ "$_id", "$$rssObjID" ] } } }
            ],
            "as": "rssDetails"
          }
        },
        {
            "$unwind": "$rssDetails"
        },
        { "$lookup": {
            "let": { "siteObjID": { "$toObjectId": "$rssDetails.site" } },
            "from": "news_sites",
            "pipeline": [
              { "$match": { "$expr": { "$eq": [ "$_id", "$$siteObjID" ] } } }
            ],
            "as": "siteDetails"
          }
        },
        {
            $unwind: "$siteDetails"
        },
        { "$lookup": {
            "let": { "categoryObjID": { "$toObjectId": "$rssDetails.category" } },
            "from": "categories",
            "pipeline": [
              { "$match": { "$expr": { "$eq": [ "$_id", "$$categoryObjID" ] } } }
            ],
            "as": "categoryDetails"
          }
        },
        {
            $unwind: "$categoryDetails"
        },
        { "$skip": limit * page},  { "$limit": limit},
    ]

    if (filterSites.length > 0 || filterCategories.length > 0) {
        aggregateQuery = [
            { "$lookup": {
                "let": { "rssObjID": { "$toObjectId": "$rss" } },
                "from": "rsses",
                "pipeline": [
                  { "$match": { "$expr": { "$eq": [ "$_id", "$$rssObjID" ] } } }
                ],
                "as": "rssDetails"
              }
            },
            {
                "$unwind": "$rssDetails"
            },
            { "$lookup": {
                "let": { "siteObjID": { "$toObjectId": "$rssDetails.site" } },
                "from": "news_sites",
                "pipeline": [
                  { "$match": { "$expr": { "$eq": [ "$_id", "$$siteObjID" ] } } }
                ],
                "as": "siteDetails"
              }
            },
            {
                $unwind: "$siteDetails"
            },
            { "$lookup": {
                "let": { "categoryObjID": { "$toObjectId": "$rssDetails.category" } },
                "from": "categories",
                "pipeline": [
                  { "$match": { "$expr": { "$eq": [ "$_id", "$$categoryObjID" ] } } }
                ],
                "as": "categoryDetails"
              }
            },
            {
                $unwind: "$categoryDetails"
            },
            { "$match" : {
                "$and" : [
                    {$or : [{"title": new RegExp(searchWord, "i")},{"description": new RegExp(searchWord, "i")},{"body": new RegExp(searchWord, "i")}]},
                    {
                        "$and" : 
                    [ 
                        { "rssDetails.category" : { "$in": filterCategories } }, 
                        { "rssDetails.site" : { "$in": filterSites } }  
                    ]}   
                ]}},
            { "$skip": limit * page},  { "$limit": limit},
        ]
    }

    

    const allNews = News.aggregate(aggregateQuery)
        
   
    const data = []

    for await (const news of allNews)
    {   

        delete news.siteDetails.__v
        delete news.rssDetails.__v
        delete news.rssDetails.site
        delete news.rssDetails.category
        delete news.categoryDetails.__v
        data.push(news)
    
    }
    res.send(data)


})


module.exports = router