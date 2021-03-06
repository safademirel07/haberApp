const express = require("express")
const os = require("os")
const db = require("./db/mongoose")
var bodyParser = require('body-parser')

//const parserRouter = require("./routers/parser")
const newsSiteRouter = require("./routers/news_site")
const rssRouter = require("./routers/rss")
const newsRouter = require("./routers/news")
const userRouter = require("./routers/user")
const commentRouter = require("./routers/comment")
const logRouter = require("./routers/log")
const landingRouter = require("./routers/landing")

const sabahParser = require("./parsers/sabah")
const milliyetParser = require("./parsers/milliyet")
const haberTurkParser = require("./parsers/haberturk")
const cnnTurkParser = require("./parsers/cnnturk")
const ntvParser = require("./parsers/ntv")

var CronJob = require('cron').CronJob;
const moment = require("moment")


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
app.use(userRouter)
app.use(commentRouter)
app.use(logRouter)
app.use(landingRouter)


moment.locale("tr")

app.use(express.static('public'))



const job = new CronJob('0 */5 * * * *', function() {
    
    sabahParser.parseSabahNews()
    milliyetParser.parseMilliyetNews()
    haberTurkParser.parseHaberTurkNews()
    cnnTurkParser.parseCNNTurkNews()
    ntvParser.parseNtvNews()
    const d = new Date();
    console.log('Cron worked at date : ', d);
});  


job.start()



app.listen(port, () => {
    console.log("Server is up on port ", port)
})
