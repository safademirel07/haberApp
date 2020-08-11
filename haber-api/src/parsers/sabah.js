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

async function parseSabahNews() {

    const newsSite = await NewsSite.findOne({
        "_id": constants.sabahSiteID
    })

    if (!newsSite) {
        console.log("News Site (Sabah) doesn't exists in database.")
        return
    }

    const rss = await RSS.find({
        "site": newsSite._id
    })

    if (rss.length == 0) {
        console.log("News Site (Sabah) doesn't have RSS feeds.")
        return
    }

    for (const rssSource of rss) {
        const rssURL = rssSource.url
        const rssID = rssSource._id
        const rssCategory = rssSource.category
        await parseRSS(rssURL, rssID, rssCategory)
        console.log(rssSource)
        
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
    var allNews = newsJSON.rss.channel[0].item
    var createdNewsCount = 0
    var failedNewsCount = 0

    if (allNews.length == 0) {
        return
    }

    for await (const item of allNews) {
        const newsItemUrl = item.link[0]
        const isExists = await News.findOne({
            "link": newsItemUrl
        })
        const isFailed = await FailedNews.findOne({
            "url": newsItemUrl
        })

        if (!isExists && !isFailed) {
            if (item.enclosure == undefined) {
                continue
            }

            const responseHTML = await fetch(item.link[0]);
            const dataHTML = await responseHTML.text();
            const $ = cheerio.load(dataHTML, {
                xmlMode: true
            });
            const onlyJson = $('[type="application/ld+json"]')

            var unixTimeStamp = moment(item.pubDate[0]).unix();
            
            var body = "Haber içeriği yüklenemedi."
            try {
                body = JSON.parse(onlyJson.get()[0].children[0].data).articleBody.trim();
            } catch (e) {
                body = "Haber içeriği yüklenemedi."
            }

            if (body == undefined)
                body = "Haber içeriği yüklenemedi."
            
            try {
                const createNews = new News({
                    rss: rssID,
                    title: item.title[0],
                    description: striptags(item.description[0], [], ' ').trim(),
                    body: body,
                    date: unixTimeStamp,
                    link: newsItemUrl,
                    image: item.enclosure[0]["$"].url,
                })

                

                createNews.save()
                    ++createdNewsCount
                console.log("Title : " + item.title[0] + ", URL: " + newsItemUrl + " created.")
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
    parseSabahNews,
}