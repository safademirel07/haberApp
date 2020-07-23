const express = require("express")
const router = new express.Router()
const News = require("../models/news")
const RSS = require("../models/rss")
const NewsSite = require("../models/news_site")
const mongoose = require("mongoose")
const moment = require("moment")

const auth = require("../middleware/auth")

// @route    GET news/get?news_sites=(id1,id2)&categories=(id1,id2)&searchWord=xyz&page=1
// @desc     Gets news specified News Sites, Categories, Search Word with pagination.
// to-do     Implement sort with date.
router.get("/news/get", async (req, res) => {

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


  var aggregateQuery = [{
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
    },
    {
      "$unwind": "$rssDetails"
    },
    {
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
    },
    {
      $unwind: "$siteDetails"
    },
    {
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
    {
      "$sort": {
        date: -1
      }
    },
    {
      "$skip": limit * page
    }, {
      "$limit": limit
    },
  ]

  if (filterSites.length > 0 || filterCategories.length > 0) {
    aggregateQuery = [{
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
      },
      {
        "$unwind": "$rssDetails"
      },
      {
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
      },
      {
        $unwind: "$siteDetails"
      },
      {
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
      {
        "$match": {
          "$and": [{
              $or: [{
                "title": new RegExp(searchWord, "i")
              }, {
                "description": new RegExp(searchWord, "i")
              }, {
                "body": new RegExp(searchWord, "i")
              }]
            },
            {
              "$and": [{
                  "rssDetails.category": {
                    "$in": filterCategories
                  }
                },
                {
                  "rssDetails.site": {
                    "$in": filterSites
                  }
                }
              ]
            }
          ]
        }
      },
      {
        "$sort": {
          date: -1
        }
      },

      {
        "$skip": limit * page
      }, {
        "$limit": limit
      },
    ]
  }



  const allNews = News.aggregate(aggregateQuery)


  const data = []

  for await (const news of allNews) {

    delete news.__v
    delete news.rss
    delete news.siteDetails.__v
    delete news.rssDetails.__v
    delete news.rssDetails.site
    delete news.rssDetails.category
    delete news.categoryDetails.__v
    const likes = news.likes.length
    const dislikes = news.dislikes.length
    delete news.likes
    delete news.dislikes
    news["likes"] = likes
    news["dislikes"] = dislikes

    news.date = moment.unix(news.date).format("LLLL")
    data.push(news)

  }
  res.send(data)


})

router.get("/news/slider", async (req, res) => {

  let limit = 10; //news per page


  const newsSites = req.query.news_sites
  let page = (Math.abs(req.query.page) || 1) - 1;



  console.log(newsSites)

  var filterSites = []

  if (newsSites != undefined && newsSites.length > 0) {
    var splitNewsSites = newsSites.split(',')
    splitNewsSites.forEach(newsSite => {
      filterSites.push(mongoose.Types.ObjectId(newsSite))
    });
  }

  console.log("filterSites" + filterSites)

  var latestID = mongoose.Types.ObjectId("5f135127c961bd0bb0ba82b7")
  var homeID = mongoose.Types.ObjectId("5f135136c961bd0bb0ba82b8")


  var aggregateQuery = [{
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
    },
    {
      "$unwind": "$rssDetails"
    },
    {
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
    },
    {
      $unwind: "$siteDetails"
    },
    {
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
    {
      "$match": {
        "rssDetails.category": {
          "$in": [latestID, homeID]
        }
      }
    },
    {
      "$sort": {
        date: -1 //date by Descending
      }
    },
    {
      "$skip": limit * page
    }, {
      "$limit": limit
    },
  ]

  if (filterSites.length > 0) {
    aggregateQuery = [{
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
      },
      {
        "$unwind": "$rssDetails"
      },
      {
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
      },
      {
        $unwind: "$siteDetails"
      },
      {
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
      {
        "$match": {

          "$and": [{
              "rssDetails.category": {
                "$in": [latestID, homeID]
              }
            },
            {
              "rssDetails.site": {
                "$in": filterSites
              }
            }
          ]
        }

      },
      {
        "$sort": {
          date: -1 //date by Descending
        }
      },

      {
        "$skip": limit * page
      }, {
        "$limit": limit
      },
    ]
  }



  const allNews = News.aggregate(aggregateQuery)


  const data = []

  for await (const news of allNews) {

    delete news.__v
    delete news.rss
    delete news.siteDetails.__v
    delete news.rssDetails.__v
    delete news.rssDetails.site
    delete news.rssDetails.category
    delete news.categoryDetails.__v
    const likes = news.likes.length
    const dislikes = news.dislikes.length
    delete news.likes
    delete news.dislikes
    news["likes"] = likes
    news["dislikes"] = dislikes
    news.date = moment.unix(news.date).format("LLLL")
    data.push(news)

  }
  res.send(data)
})

router.post("/news/like", auth, async (req, res) => {
  try {
    const user = req.user
    const newsID = mongoose.Types.ObjectId(req.query.news)
    const news = await News.findOne({
      _id: newsID
    }).populate("rss")

    if (news) {
      //If user clicks like, check before if it's disliked it?
      const dislikeResult = news.dislikes.filter(dislike => dislike.users.toString() == user._id.toString());
      if (dislikeResult.length > 0) {
        const removeIndexDislike = news.dislikes.map(item => item.users.toString()).indexOf(user._id.toString());
        news.dislikes.splice(removeIndexDislike, 1);
      }

      const likeResult = news.likes.filter(like => like.users.toString() == user._id.toString());
      if (likeResult.length > 0) {
        const removeIndex = news.likes.map(item => item.users.toString()).indexOf(user._id.toString());
        news.likes.splice(removeIndex, 1);
      } else {
        news.likes.unshift({
          users: user._id
        });
      }
    }

    await news.save()


    const newsObject = await news.toObject()

    delete newsObject.rss
    delete newsObject.title
    delete newsObject.description
    delete newsObject.body
    delete newsObject.date
    delete newsObject.link
    delete newsObject.image
    delete newsObject.__v

    const likesLength = newsObject.likes.length
    const disLikesLength = newsObject.dislikes.length

    delete newsObject.likes
    delete newsObject.dislikes

    const isDisliked = news.dislikes.filter(dislike => dislike.users.toString() == user._id.toString()).length;
    const isLiked = news.likes.filter(like => like.users.toString() == user._id.toString()).length;

    newsObject["isDisliked"] = isDisliked ? true : false
    newsObject["isLiked"] = isLiked ? true : false
    newsObject["likes"] = likesLength
    newsObject["dislikes"] = disLikesLength
    console.log(newsObject)

    res.send(newsObject)
  } catch (e) {
    res.status(400).send({"error" : e.toString()})
  }

})


router.post("/news/dislike", auth, async (req, res) => {
  try {
    const user = req.user
    const newsID = mongoose.Types.ObjectId(req.query.news)
    const news = await News.findOne({
      _id: newsID
    }).populate("rss")

    if (news) {
      //If user clicks like, check before if it's disliked it?
      const likeResult = news.likes.filter(like => like.users.toString() == user._id.toString());
      if (likeResult.length > 0) {
          const removeIndex = news.likes.map(item => item.users.toString()).indexOf(user._id.toString());
          news.likes.splice(removeIndex, 1);
      } 

      const dislikeResult = news.dislikes.filter(dislike => dislike.users.toString() == user._id.toString());
      if (dislikeResult.length > 0) {
          const removeIndexDislike = news.dislikes.map(item => item.users.toString()).indexOf(user._id.toString());
          news.dislikes.splice(removeIndexDislike, 1);
      }else {
          news.dislikes.unshift({ users: user._id });
      }


    }

    await news.save()


    const newsObject = await news.toObject()

    delete newsObject.rss
    delete newsObject.title
    delete newsObject.description
    delete newsObject.body
    delete newsObject.date
    delete newsObject.link
    delete newsObject.image
    delete newsObject.__v

    const likesLength = newsObject.likes.length
    const disLikesLength = newsObject.dislikes.length

    delete newsObject.likes
    delete newsObject.dislikes

    const isDisliked = news.dislikes.filter(dislike => dislike.users.toString() == user._id.toString()).length;
    const isLiked = news.likes.filter(like => like.users.toString() == user._id.toString()).length;

    newsObject["isDisliked"] = isDisliked ? true : false
    newsObject["isLiked"] = isLiked ? true : false
    newsObject["likes"] = likesLength
    newsObject["dislikes"] = disLikesLength
    console.log(newsObject)

    res.send(newsObject)
  } catch (e) {
    res.status(400).send({"error" : e.toString()})
  }

})



module.exports = router