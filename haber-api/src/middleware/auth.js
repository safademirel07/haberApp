const jwt = require("jsonwebtoken")
const User = require("../models/user")
const constants = require("../others/constants")

const auth = async (req, res, next) => {
    try {
        const token = req.header("Authorization").replace("Bearer ","")
        const decoded = jwt.verify(token, constants.secretKey)

        const user = await User.findOne({_id : decoded._id, "tokens.token" : token})
        
        if (!user) {
            throw new Error()
        }

        req.token = token
        req.user = user
        next() 
    } catch (e) {
        res.status(401).send({ error: "Please authenticate."})
    }
}

const auth_test = async (req, res, next) => {
    try {
        const token = req.header("Authorization").replace("Bearer ","")
        const decoded = jwt.verify(token, constants.secretKey)

        const user = await User.findOne({_id : decoded._id, "tokens.token" : token})
        
        if (!user) {
            req.user = undefined
            next()    
        }

        req.token = token
        req.user = user
        next() 
    } catch (e) {
        req.user = undefined
        next()
        //res.status(401).send({ error: "Please authenticate."})
    }
}


module.exports = {auth, auth_test}