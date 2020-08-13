var striptags = require('striptags');
const cheerio = require('cheerio');
const fetch = require("node-fetch");
var parseString = require('xml2js').parseString;

const News = require("../models/news");
const NewsSite = require('../models/news_site');
const RSS = require('../models/rss');
const FailedNews = require('../models/failed_news');
const constants = require('../others/constants');
const moment = require("moment")

async function parseNtvNews() {

    const newsSite = await NewsSite.findOne({
        "_id": constants.ntvSiteID
    })

    if (!newsSite) {
        console.log("News Site (NTV) doesn't exists in database.")
        return
    }

    const rss = await RSS.find({
        "site": newsSite._id
    })

    if (rss.length == 0) {
        console.log("News Site (NTV) doesn't have RSS feeds.")
        return
    }

    for (const rssSource of rss) {
        const rssURL = rssSource.url
        const rssID = rssSource._id
        const rssCategory = rssSource.category
        await parseRSS(rssURL, rssID, rssCategory)
        
    }


}

function parseXml(body) {
    var parsed;
    parseString(body, function (err, result) {
        if (err) {
            throw err;
        } else {
            parsed = result;
        }
    });

    return parsed;
}


async function parseRSS(rssURL, rssID, rssCategory) {

    const fetchXML = await fetch(rssURL)
    const dataXML = await fetchXML.text();
    const parsedXML = await parseXml(dataXML);
    const newsJSON = JSON.parse(JSON.stringify(parsedXML));
    var allNews = newsJSON.feed.entry
    var createdNewsCount = 0
    var failedNewsCount = 0




    for await (const item of allNews) {

        const newsItemUrl = item.id[0]

        const isExists = await News.findOne({
            "link": newsItemUrl
        })
        const isFailed = await FailedNews.findOne({
            "url": newsItemUrl
        })

        if (!isExists && !isFailed) {


            const title = item.title[0]["_"]
            const description = item.summary[0]["_"].trim()
            const datePublished = item.published[0]

            const imageHtml = cheerio.load(item.content[0]["_"], {
                xmlMode: true
            })
            const itemImage = imageHtml('img').attr('src')

            var unixTimeStamp = moment(datePublished).unix();

            var newBody = "Haber içeriği yüklenemedi."
            try {
                newBody = striptags(item.content[0]["_"], [], ' ').trim()
            } catch {
                newBody = "Haber içeriği yüklenemedi."
            }

            if (newBody == undefined)
            newBody = "Haber içeriği yüklenemedi."
            

            try {
                const createNews = new News({
                    rss: rssID,
                    title: title,
                    description: description,
                    body: newBody,
                    date: unixTimeStamp,
                    link: newsItemUrl,
                    image: itemImage,
                })


                createNews.save()
                    ++createdNewsCount
                console.log("Title : " + title + ", URL: " + newsItemUrl + " created.")
            } catch (e) {
                const createFailedNews = new FailedNews({
                    "url": newsItemUrl
                })
                createFailedNews.save()
                    ++failedNewsCount
                console.log("News URL: " + newsItemUrl + " couldn't fetched. Error: " + e);
                continue
            }
        }

    }
    console.log("rssCategory : " + rssCategory + " Success: " + createdNewsCount + " Fail: " + failedNewsCount)
}


module.exports = {
    parseNtvNews,
}