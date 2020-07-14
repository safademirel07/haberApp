const express = require("express")
const os = require("os")
const db = require("./db/mongoose")
var bodyParser = require('body-parser')

const parserRouter = require("./routers/parser")


const app = express()
const port = process.env.PORT || 3000

// Body Parser ( Parses the text as JSON and exposes the resulting object on req.body.)
app.use(bodyParser.json({limit: '100mb', extended: true}))
app.use(bodyParser.urlencoded({limit: '100mb', extended: true}))
app.use(express.json())
app.use(parserRouter)

app.use(express.static('public'))



app.listen(port, () => {
    console.log("Server is up on port ", port)
})
