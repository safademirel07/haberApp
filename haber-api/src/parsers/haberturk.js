var striptags = require('striptags');
const cheerio = require('cheerio');
const fetch = require("node-fetch");
var parseString = require('xml2js').parseString;

const News = require("../models/news");
const NewsSite = require('../models/news_site');
const FailedNews = require('../models/failed_news');
const RSS = require('../models/rss');
const constants = require('../others/constants');
const moment = require("moment")

async function parseHaberTurkNews() {

    const newsSite = await NewsSite.findOne({
        "_id": constants.haberTurkSiteID
    })

    if (!newsSite) {
        console.log("News Site (Habertürk) doesn't exists in database.")
        return
    }

    const rss = await RSS.find({
        "site": newsSite._id
    })

    if (rss.length == 0) {
        console.log("News Site (Habertürk) doesn't have RSS feeds.")
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
    try {

        const fetchXML = await fetch(rssURL)
        const dataXML = await fetchXML.text();

        if (dataXML.length <= 0) {
            console.log("Empty page. " + rssURL)
            return
        }

        const parsedXML = await parseXml(dataXML);

        const newsJSON = JSON.parse(JSON.stringify(parsedXML));
        var allNews = newsJSON.rss.channel[0].item
        var createdNewsCount = 0
        var failedNewsCount = 0


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

                const responseHtml = await fetch(item.link[0]);
                const dataHtml = await responseHtml.text();
                const $ = cheerio.load(dataHtml, {
                    xmlMode: true
                });
                const onlyJson = $('[type="application/ld+json"]')

                var unixTimeStamp = moment(item.pubDate[0]).unix();

                try {
                    const createNews = new News({
                        rss: rssID,
                        title: item.title[0],
                        description: striptags(item.description[0], [], ' '),
                        body: JSON.parse(onlyJson.get()[2].children[0].data).articleBody.trim(),
                        date: unixTimeStamp,
                        link: item.link[0],
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


    } catch (e) {
        console.log("HaberTürk hata" + e)
    }
}


module.exports = {
    parseHaberTurkNews,
}