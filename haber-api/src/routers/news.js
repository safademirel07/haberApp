const express = require("express")
const router = new express.Router()
const News = require("../models/news")
const RSS = require("../models/rss")
const NewsSite = require("../models/news_site")
const mongoose = require("mongoose")
const moment = require("moment")

var auth = require("../middleware/auth")


// @route    GET news/get?news_sites=(id1,id2)&categories=(id1,id2)&searchWord=xyz&page=1
// @desc     Gets news specified News Sites, Categories, Search Word with pagination.
// to-do     Implement sort with date.
router.get("/news/get", auth.auth_test, async (req, res) => {

  const user = req.user

  console.log("user ne? " + user)

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

    var isLiked = false, isDisliked = false, isFavorited = false

    if (user != undefined)
    {
      isLiked = news.likes.filter(like => like.users.toString() == user._id.toString()).length > 0 ? true : false
      isDisliked = news.dislikes.filter(dislike => dislike.users.toString() == user._id.toString()).length > 0 ? true : false
      isFavorited = user.favorites.filter(favorite => favorite.news.toString() == news._id.toString()).length > 0 ? true : false
    }

    delete news.likes
    delete news.dislikes
    news["likes"] = likes
    news["dislikes"] = dislikes



    console.log("news/list calisiyor.")

    news["isLiked"] = isLiked
    news["isDisliked"] = isDisliked
    news["isFavorited"] = isFavorited

    news.date = moment.unix(news.date).format("LLLL")
    data.push(news)

  }
  res.send(data)


})

router.get("/news/slider", auth.auth_test, async (req, res) => {


  const user = req.user

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

    var isLiked = false, isDisliked = false, isFavorited = false

    if (user != undefined)
    {
      isLiked = news.likes.filter(like => like.users.toString() == user._id.toString()).length > 0 ? true : false
      isDisliked = news.dislikes.filter(dislike => dislike.users.toString() == user._id.toString()).length > 0 ? true : false
      isFavorited = user.favorites.filter(favorite => favorite.news.toString() == news._id.toString()).length > 0 ? true : false
    }

    delete news.likes
    delete news.dislikes
    news["likes"] = likes
    news["dislikes"] = dislikes



    console.log("news/slider calisiyor.")

    news["isLiked"] = isLiked
    news["isDisliked"] = isDisliked
    news["isFavorited"] = isFavorited

    news.date = moment.unix(news.date).format("LLLL")
    data.push(news)

  }
  res.send(data)
})

router.post("/news/like", auth.auth, async (req, res) => {
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


router.post("/news/dislike", auth.auth, async (req, res) => {
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

router.post("/news/view", async (req, res) => {
  try {
    const newsID = mongoose.Types.ObjectId(req.query.news)
    const news = await News.findOne({
      _id: newsID
    }).populate("rss")

    if (news) {
      await news.updateOne({$inc: {'viewers': 1}})
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
      newsObject["viewers"] =  newsObject["viewers"]+1
      newsObject["likes"] = likesLength
      newsObject["dislikes"] = disLikesLength
  
      res.send(newsObject)
        
    } else {
      res.status(400).send({"error" : "News not found."})
    }
  } catch (e) {
    res.status(400).send({"error" : e.toString()})
  }

})


router.post("/news/save", auth.auth, async (req, res) => {
  try {
    const user = req.user
    const newsID = mongoose.Types.ObjectId(req.query.news)
    const news = await News.findOne({
      _id: newsID
    })




    if (news) {
      const saveResult = user.favorites.filter(favorite => favorite.news.toString() == news._id.toString());
      if (saveResult.length > 0) {
          const removeIndexFavorite = user.favorites.map(favorite => favorite.news.toString()).indexOf(news._id.toString());
          user.favorites.splice(removeIndexFavorite, 1);
      }else {
        user.favorites.unshift({ news: newsID });
      }

      await user.save()


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
      const isFavorited = user.favorites.filter(favorite => favorite.news.toString() == news._id.toString()).length > 0 ? true : false

      newsObject["isDisliked"] = isDisliked ? true : false
      newsObject["isLiked"] = isLiked ? true : false
      newsObject["isFavorited"] = isFavorited ? true : false
      newsObject["likes"] = likesLength
      newsObject["dislikes"] = disLikesLength
      console.log(newsObject)
  
      res.send(newsObject)
  

    }
  } catch (e) {
    res.status(400).send({"error" : e.toString()})
  }

})

router.get("/news/favorite", auth.auth, async (req, res) => {

  const user = req.user


  let limit = 10; //news per page

  const searchWord = req.query.search
  let page = (Math.abs(req.query.page) || 1) - 1;

  var allFavoriteNews = []

  user.favorites.forEach(favorite => {
    allFavoriteNews.push(mongoose.Types.ObjectId(favorite.news))
    console.log("favorite news id " + favorite.news)
  })




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

        
          "_id": {
            "$in": allFavoriteNews,
          }
        }
    },
    {
      "$skip": limit * page
    }, {
      "$limit": limit
    },
  ]




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

    var isLiked = false, isDisliked = false, isFavorited = false

    if (user != undefined)
    {
      isLiked = news.likes.filter(like => like.users.toString() == user._id.toString()).length > 0 ? true : false
      isDisliked = news.dislikes.filter(dislike => dislike.users.toString() == user._id.toString()).length > 0 ? true : false
      isFavorited = user.favorites.filter(favorite => favorite.news.toString() == news._id.toString()).length > 0 ? true : false
    }

    delete news.likes
    delete news.dislikes
    news["likes"] = likes
    news["dislikes"] = dislikes



    console.log("news/favorites calisiyor.")

    news["isLiked"] = isLiked
    news["isDisliked"] = isDisliked
    news["isFavorited"] = isFavorited

    news.date = moment.unix(news.date).format("LLLL")
    data.push(news)


  }
  res.send(data)
}
)


router.get("/news/anonymous_favorite", async (req, res) => {

  let limit = 10; //news per page
  const selectedFavorites = req.query.favorites

  let page = (Math.abs(req.query.page) || 1) - 1;

  var allFavoriteNews = []

  if (selectedFavorites != undefined && selectedFavorites.length > 0) {
    var splitFavorites = selectedFavorites.split(',')
    for (const favorite of splitFavorites) {

    
      try {
        allFavoriteNews.push(mongoose.Types.ObjectId(favorite))
      } catch (e) {
        continue
      }
    }
  } 

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

        
          "_id": {
            "$in": allFavoriteNews,
          }
        }
    },
    {
      "$skip": limit * page
    }, {
      "$limit": limit
    },
  ]




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



    console.log("news/favorites calisiyor.")

    news["isLiked"] = false
    news["isDisliked"] = false
    news["isFavorited"] = true

    news.date = moment.unix(news.date).format("LLLL")
    data.push(news)


  }
  res.send(data)
}
)

// @route    GET news/likes
// @desc     Gets all liked posts by user
router.get("/news/likes", auth.auth, async (req, res) => {

  const user = req.user

  if (!user) {
    res.send({
      "error": true,
      "msg": "No user"
    })
    return
  }


  let limit = 10; //news per page

  const searchWord = req.query.search
  let page = (Math.abs(req.query.page) || 1) - 1;


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
        "likes": {
          "$elemMatch": {
            users: user._id
          }
        }
      }
    },

    {
      "$skip": limit * page
    }, {
      "$limit": limit
    },
  ]

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

    var isLiked = false,
      isDisliked = false,
      isFavorited = false

    if (user != undefined) {
      isLiked = news.likes.filter(like => like.users.toString() == user._id.toString()).length > 0 ? true : false
      isDisliked = news.dislikes.filter(dislike => dislike.users.toString() == user._id.toString()).length > 0 ? true : false
      isFavorited = user.favorites.filter(favorite => favorite.news.toString() == news._id.toString()).length > 0 ? true : false
    }

    delete news.likes
    delete news.dislikes
    news["likes"] = likes
    news["dislikes"] = dislikes



    console.log("news/likes calisiyor.")

    news["isLiked"] = isLiked
    news["isDisliked"] = isDisliked
    news["isFavorited"] = isFavorited

    news.date = moment.unix(news.date).format("LLLL")
    data.push(news)


  }
  res.send(data)
}

)


// @route    GET news/dislikes
// @desc     Gets all disliked posts by user
router.get("/news/dislikes", auth.auth, async (req, res) => {

  const user = req.user

  if (!user) {
    res.send({
      "error": true,
      "msg": "No user"
    })
    return
  }


  let limit = 10; //news per page

  const searchWord = req.query.search
  let page = (Math.abs(req.query.page) || 1) - 1;


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
        "dislikes": {
          "$elemMatch": {
            users: user._id
          }
        }
      }
    },
    {
      "$skip": limit * page
    }, {
      "$limit": limit
    },
  ]

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

    var isLiked = false,
      isDisliked = false,
      isFavorited = false

    if (user != undefined) {
      isLiked = news.likes.filter(like => like.users.toString() == user._id.toString()).length > 0 ? true : false
      isDisliked = news.dislikes.filter(dislike => dislike.users.toString() == user._id.toString()).length > 0 ? true : false
      isFavorited = user.favorites.filter(favorite => favorite.news.toString() == news._id.toString()).length > 0 ? true : false
    }

    delete news.likes
    delete news.dislikes
    news["likes"] = likes
    news["dislikes"] = dislikes

    news["isLiked"] = isLiked
    news["isDisliked"] = isDisliked
    news["isFavorited"] = isFavorited

    console.log("news/dislikes calisiyor.")


    news.date = moment.unix(news.date).format("LLLL")
    data.push(news)


  }
  res.send(data)
}

)





module.exports = router