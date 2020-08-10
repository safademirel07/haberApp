const express = require("express")
const router = new express.Router()
const News = require("../models/news")
const RSS = require("../models/rss")
const NewsSite = require("../models/news_site")
const mongoose = require("mongoose")
const moment = require("moment")

var auth = require("../middleware/auth")

const firebaseAdmin = require("../firebase/firebase")
const constants = require("../others/constants")



// @route    GET news/get?news_sites=(id1,id2)&categories=(id1,id2)&searchWord=xyz&page=1
// @desc     Gets news specified News Sites, Categories, Search Word with pagination.
// to-do     Implement sort with date.
router.get("/news/get", auth.auth_test, async (req, res) => {
  const user = req.user
  let limit = 10; //news per page
  const newsSites = req.query.news_sites
  const categories = req.query.categories
  let page = (Math.abs(req.query.page) || 1) - 1;

  var filterSites = []
  var filterCategories = []

  if (newsSites != undefined && newsSites.length > 0) {
    var splitNewsSites = newsSites.split(',')
    splitNewsSites.forEach(newsSite => {
      filterSites.push(mongoose.Types.ObjectId(newsSite))
    });
  }
  if (categories != undefined && categories.length > 0) {
    var splitCategories = categories.split(',')
    splitCategories.forEach(category => {
      filterCategories.push(mongoose.Types.ObjectId(category))
    });
  }

  const searchWord = req.query.search
  const sort = req.query.sort
  const search = searchWord == undefined ? "" : searchWord
  var sortMethod = {date : -1}


  if (sort == 0) { // newest to old
      sortMethod = {date : -1}
  } else if (sort == 1) {
      sortMethod = {date : 1}
  }
  else if (sort == 2) { // newest to old
      sortMethod = {viewers_unique : -1}
  } else if (sort == 3) {
      sortMethod = {viewers_unique : 1}
  }

  const constantQuery = constants.constantQueryPart
  var aggregateQuery = [constantQuery[0], constantQuery[1], constantQuery[2], constantQuery[3], constantQuery[4], constantQuery[5],
    {
      "$match": {
        $or: [{
          "title": {
            '$regex': search,
            '$options': 'i'
          }, 
          "description": {
            '$regex': search,
            '$options': 'i'
          }, 
          "body": {
            '$regex': search,
            '$options': 'i'
          }
        }, ],
      }
    },

    {
      $addFields: {uniqueViews : { $cond: { if: { $isArray: "$viewers_unique" }, then: { $size: "$viewers_unique" }, else:0} }},
    }
    , {
      "$sort": sortMethod
    },
    {
      "$skip": limit * page
    }, {
      "$limit": limit
    },
  ]

  if (filterSites.length > 0 || filterCategories.length > 0) {
    aggregateQuery = [constantQuery[0], constantQuery[1], constantQuery[2], constantQuery[3], constantQuery[4], constantQuery[5],
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
        $addFields: {uniqueViews : { $cond: { if: { $isArray: "$viewers_unique" }, then: { $size: "$viewers_unique" }, else:0} }},
      },
      {
        "$sort": sortMethod
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

    const likes = news.likes.length
    const dislikes = news.dislikes.length
    var isLiked = false, isDisliked = false, isFavorited = false

    if (user != undefined)
    {
      isLiked = news.likes.filter(like => like.users.toString() == user._id.toString()).length > 0 ? true : false
      isDisliked = news.dislikes.filter(dislike => dislike.users.toString() == user._id.toString()).length > 0 ? true : false
      isFavorited = user.favorites.filter(favorite => favorite.news.toString() == news._id.toString()).length > 0 ? true : false
    }

    delete news.__v
    delete news.rss
    delete news.siteDetails.__v
    delete news.rssDetails.__v
    delete news.rssDetails.site
    delete news.rssDetails.category
    delete news.categoryDetails.__v
    delete news.viewers_unique
    delete news.likes
    delete news.dislikes 

    news["likes"] = likes
    news["dislikes"] = dislikes
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
  var filterSites = []

  if (newsSites != undefined && newsSites.length > 0) {
    var splitNewsSites = newsSites.split(',')
    splitNewsSites.forEach(newsSite => {
      filterSites.push(mongoose.Types.ObjectId(newsSite))
    });
  }

  var latestID = mongoose.Types.ObjectId("5f135127c961bd0bb0ba82b7")
  var homeID = mongoose.Types.ObjectId("5f135136c961bd0bb0ba82b8")

  const searchWord = req.query.search
  const sort = req.query.sort
  const search = searchWord == undefined ? "" : searchWord
  var sortMethod = {date : -1}

  if (sort == 0) { // newest to old
      sortMethod = {date : -1}
  } else if (sort == 1) {
      sortMethod = {date : 1}
  }
  else if (sort == 2) { // newest to old
      sortMethod = {uniqueViews : -1}
  } else if (sort == 3) {
      sortMethod = {uniqueViews : 1}
  }


  const constantQuery = constants.constantQueryPart

  var aggregateQuery = [constantQuery[0],constantQuery[1],constantQuery[2],constantQuery[3],constantQuery[4],constantQuery[5],
    {
      "$match": {
        "rssDetails.category": {
          "$in": [latestID, homeID]
        },
        
          $or: [{
            "title": {
              '$regex': search,
              '$options': 'i'
            }, 
            "description": {
              '$regex': search,
              '$options': 'i'
            }, 
            "body": {
              '$regex': search,
              '$options': 'i'
            }
          }, ],
        
      }
    },
    {
      $addFields: {uniqueViews: { $cond: { if: { $isArray: "$viewers_unique" }, then: { $size: "$viewers_unique" }, else:0} }},
    }, {
      "$sort": sortMethod
    },
    {
      "$skip": limit * page
    }, {
      "$limit": limit
    },
  ]

  if (filterSites.length > 0) {
    aggregateQuery = [constantQuery[0], constantQuery[1], constantQuery[2], constantQuery[3], constantQuery[4], constantQuery[5],
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
          },
          {
            $or: [{
              "title": {
                '$regex': search,
                '$options': 'i'
              }, 
              "description": {
                '$regex': search,
                '$options': 'i'
              }, 
              "body": {
                '$regex': search,
                '$options': 'i'
              }
            }, ],
          }
        ]
      }

    },
    {
      $addFields: {uniqueViews: { $cond: { if: { $isArray: "$viewers_unique" }, then: { $size: "$viewers_unique" }, else:0} }},
    }, {
      "$sort": sortMethod
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
    const likes = news.likes.length
    const dislikes = news.dislikes.length
    var isLiked = false, isDisliked = false, isFavorited = false

    if (user != undefined)
    {
      isLiked = news.likes.filter(like => like.users.toString() == user._id.toString()).length > 0 ? true : false
      isDisliked = news.dislikes.filter(dislike => dislike.users.toString() == user._id.toString()).length > 0 ? true : false
      isFavorited = user.favorites.filter(favorite => favorite.news.toString() == news._id.toString()).length > 0 ? true : false
    }

    delete news.__v
    delete news.rss
    delete news.siteDetails.__v
    delete news.rssDetails.__v
    delete news.rssDetails.site
    delete news.rssDetails.category
    delete news.categoryDetails.__v
    delete news.viewers_unique
    delete news.likes
    delete news.dislikes 

    news["likes"] = likes
    news["dislikes"] = dislikes
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

    const likesLength = newsObject.likes.length
    const disLikesLength = newsObject.dislikes.length
    const isDisliked = news.dislikes.filter(dislike => dislike.users.toString() == user._id.toString()).length;
    const isLiked = news.likes.filter(like => like.users.toString() == user._id.toString()).length;
    const isFavorited = user.favorites.filter(favorite => favorite.news.toString() == news._id.toString()).length > 0 ? true : false
    const uniqueViews = news.viewers_unique == undefined ? 0 : news.viewers_unique.length

    delete newsObject.rss
    delete newsObject.title
    delete newsObject.description
    delete newsObject.body
    delete newsObject.date
    delete newsObject.link
    delete newsObject.image
    delete newsObject.__v
    delete newsObject.likes
    delete newsObject.dislikes
    delete news.viewers_unique

    newsObject["isFavorited"] = isFavorited
    newsObject["isDisliked"] = isDisliked ? true : false
    newsObject["isLiked"] = isLiked ? true : false
    newsObject["likes"] = likesLength
    newsObject["dislikes"] = disLikesLength
    newsObject["uniqueViews"] = uniqueViews

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

    const likesLength = newsObject.likes.length
    const disLikesLength = newsObject.dislikes.length
    const isDisliked = news.dislikes.filter(dislike => dislike.users.toString() == user._id.toString()).length;
    const isLiked = news.likes.filter(like => like.users.toString() == user._id.toString()).length;
    const isFavorited = user.favorites.filter(favorite => favorite.news.toString() == news._id.toString()).length > 0 ? true : false
    const uniqueViews = news.viewers_unique == undefined ? 0 : news.viewers_unique.length


    delete newsObject.rss
    delete newsObject.title
    delete newsObject.description
    delete newsObject.body
    delete newsObject.date
    delete newsObject.link
    delete newsObject.image
    delete newsObject.__v
    delete newsObject.likes
    delete newsObject.dislikes 
    delete news.viewers_unique

    newsObject["isFavorited"] = isFavorited
    newsObject["isDisliked"] = isDisliked ? true : false
    newsObject["isLiked"] = isLiked ? true : false
    newsObject["likes"] = likesLength
    newsObject["dislikes"] = disLikesLength
    newsObject["uniqueViews"] = uniqueViews

    




    res.send(newsObject)
  } catch (e) {
    res.status(400).send({"error" : e.toString()})
  }

})

router.post("/news/view", auth.auth_test, async (req, res) => {
  const user = req.user
  const authToken = req.query.authToken;
  const uid = req.query.uid;
  const decodedClaims = await firebaseAdmin.auth().verifyIdToken(authToken)

  if (uid != decodedClaims.uid){
    res.status(400).send({"error" : "uid and decoded uid is not same."})
  }

  try {
    const newsID = mongoose.Types.ObjectId(req.query.news)
    const news = await News.findOne({
      _id: newsID
    }).populate("rss")

    if (news) {
      var alreadyViewed = news.viewers_unique == undefined ? false : news.viewers_unique.filter(unique => unique.firebaseID.toString() == uid).length > 0 ? true : false
        if (!alreadyViewed)
        {
          var unique = {"firebaseID" : uid, "count" : 1}
          await news.viewers_unique.unshift(unique)
          await news.save()
        } else {
          // Needs to rework...
          const viewerUnique = news.viewers_unique.filter(unique => unique.firebaseID.toString() == uid)
          const newValue = viewerUnique[0].count+1
          const removeIndex = news.viewers_unique.map(unique => unique.firebaseID.toString() == uid)
          var unique = {"firebaseID" : uid, "count" : newValue}
          await news.viewers_unique.splice(removeIndex, 1);
          await news.viewers_unique.unshift(unique)
          await news.save()

        }
      await news.updateOne({$inc: {'viewers': 1}})
      await news.save()
      const newsObject = await news.toObject()

      var isLiked = false, isDisliked = false, isFavorited = false


      if (user != undefined)
      {
        isLiked = news.likes.filter(like => like.users.toString() == user._id.toString()).length > 0 ? true : false
        isDisliked = news.dislikes.filter(dislike => dislike.users.toString() == user._id.toString()).length > 0 ? true : false
        isFavorited = user.favorites.filter(favorite => favorite.news.toString() == news._id.toString()).length > 0 ? true : false
      }

      const likesLength = newsObject.likes.length
      const disLikesLength = newsObject.dislikes.length
      const uniqueViews = news.viewers_unique == undefined ? 0 : news.viewers_unique.length
  
      delete newsObject.rss
      delete newsObject.title
      delete newsObject.description
      delete newsObject.body
      delete newsObject.date
      delete newsObject.link
      delete newsObject.image
      delete newsObject.__v
      delete newsObject.likes
      delete newsObject.dislikes
      delete news.viewers_unique

      newsObject["viewers"] =  newsObject["viewers"]+1
      newsObject["likes"] = likesLength
      newsObject["dislikes"] = disLikesLength
      newsObject["isLiked"] = isLiked 
      newsObject["isDisliked"] = isDisliked
      newsObject["isFavorited"] = isFavorited
      newsObject["uniqueViews"] = uniqueViews
      
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

      const likesLength = newsObject.likes.length
      const disLikesLength = newsObject.dislikes.length
      const isDisliked = news.dislikes.filter(dislike => dislike.users.toString() == user._id.toString()).length;
      const isLiked = news.likes.filter(like => like.users.toString() == user._id.toString()).length;
      const isFavorited = user.favorites.filter(favorite => favorite.news.toString() == news._id.toString()).length > 0 ? true : false
      const uniqueViews = news.viewers_unique == undefined ? 0 : news.viewers_unique.length

      delete newsObject.rss
      delete newsObject.title
      delete newsObject.description
      delete newsObject.body
      delete newsObject.date
      delete newsObject.link
      delete newsObject.image
      delete newsObject.__v
      delete newsObject.likes
      delete newsObject.dislikes
      delete news.viewers_unique


      newsObject["isDisliked"] = isDisliked ? true : false
      newsObject["isLiked"] = isLiked ? true : false
      newsObject["isFavorited"] = isFavorited ? true : false
      newsObject["likes"] = likesLength
      newsObject["dislikes"] = disLikesLength
	    newsObject["uniqueViews"] = uniqueViews
      
      res.send(newsObject)
  

    }
  } catch (e) {
    res.status(400).send({"error" : e.toString()})
  }

})

router.get("/news/favorite", auth.auth, async (req, res) => {

  const user = req.user
  let limit = 10; //news per page

  let page = (Math.abs(req.query.page) || 1) - 1;

  var allFavoriteNews = []

  user.favorites.forEach(favorite => {
    allFavoriteNews.push(mongoose.Types.ObjectId(favorite.news))
  })

  const searchWord = req.query.search
  const sort = req.query.sort
  const search = searchWord == undefined ? "" : searchWord
  var sortMethod = {date : -1}

  if (sort == 0) { // newest to old
      sortMethod = {date : -1}
  } else if (sort == 1) {
      sortMethod = {date : 1}
  }
  else if (sort == 2) { // newest to old
      sortMethod = {uniqueViews : -1}
  } else if (sort == 3) {
      sortMethod = {uniqueViews : 1}
  }


  const constantQuery = constants.constantQueryPart
  var aggregateQuery = [constantQuery[0], constantQuery[1], constantQuery[2], constantQuery[3], constantQuery[4], constantQuery[5],

    {
      "$match": {


        "_id": {
          "$in": allFavoriteNews,
        },

        $or: [{
          "title": {
            '$regex': search,
            '$options': 'i'
          }
        }, ],


      }
    },
    {
      $addFields: {uniqueViews : { $cond: { if: { $isArray: "$viewers_unique" }, then: { $size: "$viewers_unique" }, else:0} }},
    },
    {
      "$sort": sortMethod
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
    const likes = news.likes.length
    const dislikes = news.dislikes.length
    var isLiked = false, isDisliked = false, isFavorited = false

    if (user != undefined)
    {
      isLiked = news.likes.filter(like => like.users.toString() == user._id.toString()).length > 0 ? true : false
      isDisliked = news.dislikes.filter(dislike => dislike.users.toString() == user._id.toString()).length > 0 ? true : false
      isFavorited = user.favorites.filter(favorite => favorite.news.toString() == news._id.toString()).length > 0 ? true : false
    }

    delete news.__v
    delete news.rss
    delete news.siteDetails.__v
    delete news.rssDetails.__v
    delete news.rssDetails.site
    delete news.rssDetails.category
    delete news.categoryDetails.__v
    delete news.viewers_unique
    delete news.likes
    delete news.dislikes

    news["likes"] = likes
    news["dislikes"] = dislikes
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
  const constantQuery = constants.constantQueryPart
  var aggregateQuery = [constantQuery[0], constantQuery[1], constantQuery[2], constantQuery[3], constantQuery[4], constantQuery[5],
    {
      "$match": {
          "_id": {
            "$in": allFavoriteNews,
          }
        }
    },
    {
      $addFields: {uniqueViews : { $cond: { if: { $isArray: "$viewers_unique" }, then: { $size: "$viewers_unique" }, else:0} }},
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

    const likes = news.likes.length
    const dislikes = news.dislikes.length

    news["likes"] = likes
    news["dislikes"] = dislikes
    news["isLiked"] = false
    news["isDisliked"] = false
    news["isFavorited"] = true

    delete news.__v
    delete news.rss
    delete news.siteDetails.__v
    delete news.rssDetails.__v
    delete news.rssDetails.site
    delete news.rssDetails.category
    delete news.categoryDetails.__v
    delete news.likes
    delete news.dislikes
    delete news.viewers_unique

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

  let page = (Math.abs(req.query.page) || 1) - 1;

  const searchWord = req.query.search
  const sort = req.query.sort
  const search = searchWord == undefined ? "" : searchWord
  var sortMethod = {date : -1}

  if (sort == 0) { // newest to old
      sortMethod = {date : -1}
  } else if (sort == 1) {
      sortMethod = {date : 1}
  }
  else if (sort == 2) { // newest to old
      sortMethod = {uniqueViews : -1}
  } else if (sort == 3) {
      sortMethod = {uniqueViews : 1}
  }

  const constantQuery = constants.constantQueryPart
  var aggregateQuery = [constantQuery[0], constantQuery[1], constantQuery[2], constantQuery[3], constantQuery[4], constantQuery[5],

    {
      "$match": {
        "likes": {
          "$elemMatch": {
            users: user._id
          }
        },
        
          $or: [{
            "title": {
              '$regex': search,
              '$options': 'i'
            }, 
            "description": {
              '$regex': search,
              '$options': 'i'
            }, 
            "body": {
              '$regex': search,
              '$options': 'i'
            }
          }, ],
        
      }
    },
    {
      $addFields: {uniqueViews : { $cond: { if: { $isArray: "$viewers_unique" }, then: { $size: "$viewers_unique" }, else:0} }},
    }, {
      "$sort": sortMethod
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

    delete news.__v
    delete news.rss
    delete news.siteDetails.__v
    delete news.rssDetails.__v
    delete news.rssDetails.site
    delete news.rssDetails.category
    delete news.categoryDetails.__v
    delete news.viewers_unique
    delete news.likes
    delete news.dislikes

    news["likes"] = likes
    news["dislikes"] = dislikes
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
  const sort = req.query.sort
  const search = searchWord == undefined ? "" : searchWord
  var sortMethod = {date : -1}

  if (sort == 0) { // newest to old
      sortMethod = {date : -1}
  } else if (sort == 1) {
      sortMethod = {date : 1}
  }
  else if (sort == 2) { // newest to old
      sortMethod = {uniqueViews : -1}
  } else if (sort == 3) {
      sortMethod = {uniqueViews : 1}
  }
  
  let page = (Math.abs(req.query.page) || 1) - 1;

  const constantQuery = constants.constantQueryPart
  var aggregateQuery = [constantQuery[0], constantQuery[1], constantQuery[2], constantQuery[3], constantQuery[4], constantQuery[5],
    {
      "$match": {
        "dislikes": {
          "$elemMatch": {
            users: user._id
          }
        },
        
          $or: [{
            "title": {
              '$regex': search,
              '$options': 'i'
            }, 
            "description": {
              '$regex': search,
              '$options': 'i'
            }, 
            "body": {
              '$regex': search,
              '$options': 'i'
            }
          }, ],
        
      }
    },
    {
      $addFields: {uniqueViews : { $cond: { if: { $isArray: "$viewers_unique" }, then: { $size: "$viewers_unique" }, else:0} }},
    },
     {
      "$sort": sortMethod
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



    delete news.__v
    delete news.rss
    delete news.siteDetails.__v
    delete news.rssDetails.__v
    delete news.rssDetails.site
    delete news.rssDetails.category
    delete news.categoryDetails.__v
    delete news.viewers_unique
    delete news.likes
    delete news.dislikes
    
    news["likes"] = likes
    news["dislikes"] = dislikes
    news["isLiked"] = isLiked
    news["isDisliked"] = isDisliked
    news["isFavorited"] = isFavorited

    news.date = moment.unix(news.date).format("LLLL")
    data.push(news)


  }
  res.send(data)
}

)





module.exports = router