const mongoose = require("mongoose")
const RSS = require("../models/rss")
const NewsSite = require("../models/news_site")

const newsSchema = new mongoose.Schema({
    rss: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'RSS',
        required : true,
    },
    link: {
        type: String,
        required : true,
        unique : true
    },
    title: {
        type: String,
        text : true,
        required : true,
    },
    description: {
        type: String,
        text : true,
        required : true,
    },
    body: {
        type: String,
        required : true,
        text : true,
    },
    date: {
        type: String,
        required : true,
    },
    image: {
        type: String,
        required : true,
    },
})

newsSchema.methods.toJSON = async function () {
    const news = this
    const newsObject = news.toObject()

    delete newsObject.__v
    delete newsObject.rss

    const rss = await RSS.findOne({_id: news.rss})
        
    if (!rss) {
        console.log("RSS not found.")
        return undefined
    }

    const newsSite = await NewsSite.findOne({_id : rss.site})

    if (!rss) {
        console.log("News Site not found.")
        return undefined
    }


    newsSiteName = newsSite.name
    newsCategoryName = rss.category


    const object = {...newsObject, newsSiteName, newsCategoryName}

    return object 
}

const News = mongoose.model("News",newsSchema)

module.exports = News