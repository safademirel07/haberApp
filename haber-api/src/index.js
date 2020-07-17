const express = require("express")
const os = require("os")
const db = require("./db/mongoose")
var bodyParser = require('body-parser')

//const parserRouter = require("./routers/parser")
const newsSiteRouter = require("./routers/news_site")
const rssRouter = require("./routers/rss")
const newsRouter = require("./routers/news")

const sabahParsers = require("./parsers/sabah")

const app = express()
const port = process.env.PORT || 3000

// Body Parser ( Parses the text as JSON and exposes the resulting object on req.body.)
app.use(bodyParser.json({limit: '100mb', extended: true}))
app.use(bodyParser.urlencoded({limit: '100mb', extended: true}))
app.use(express.json())
//app.use(parserRouter)
app.use(newsSiteRouter)
app.use(rssRouter)
app.use(newsRouter)

app.use(express.static('public'))

sabahParsers.parseSabahNews()


app.listen(port, () => {
    console.log("Server is up on port ", port)
})
