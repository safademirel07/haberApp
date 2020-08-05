module.exports = {
  sabahRSS: "https://www.sabah.com.tr/rss/anasayfa.xml",
  milliyetRSS: "https://www.milliyet.com.tr/rss/rssnew/gundemrss.xml",
  cnnRSS: "https://www.cnnturk.com/feed/rss/all/news",
  haberturkRSS: "http://www.haberturk.com/rss",

  sabahSiteID: "5f1351a1c961bd0bb0ba82bf",
  milliyetSiteID: "5f1351c3c961bd0bb0ba82c0",
  cnnTURKSiteID: "5f13521fc961bd0bb0ba82c1",
  haberTurkSiteID: "5f13523dc961bd0bb0ba82c2",
  ntvSiteID: "5f1366bf58a4b8083428bee1",

  secretKey: "X0U7Y>!mVp2_u<:?>``]dy0vXV`CIH",

  constantQueryPart: [{
      "$lookup": {
        "let": {
          "rssObjID": {
            "$toObjectId": "$rss"
          }
        },
        "from": "rsses",
        "pipeline": [{
          "$match": {
            "$expr": {
              "$eq": ["$_id", "$$rssObjID"]
            }
          }
        }],
        "as": "rssDetails"
      }
    }, {
      "$unwind": "$rssDetails"
    }, {
      "$lookup": {
        "let": {
          "siteObjID": {
            "$toObjectId": "$rssDetails.site"
          }
        },
        "from": "news_sites",
        "pipeline": [{
          "$match": {
            "$expr": {
              "$eq": ["$_id", "$$siteObjID"]
            }
          }
        }],
        "as": "siteDetails"
      }
    }, {
      $unwind: "$siteDetails"
    }, {
      "$lookup": {
        "let": {
          "categoryObjID": {
            "$toObjectId": "$rssDetails.category"
          }
        },
        "from": "categories",
        "pipeline": [{
          "$match": {
            "$expr": {
              "$eq": ["$_id", "$$categoryObjID"]
            }
          }
        }],
        "as": "categoryDetails"
      }
    },
    {
      $unwind: "$categoryDetails"
    },
  ]



}
