const express = require("express")
const router = new express.Router()
const mongoose = require("mongoose")
const Log = require("../models/log")
const firebaseAdmin = require("../firebase/firebase")

router.post("/log/create", async(req,res) => {

    const uid = req.body.firebaseUID
    const authToken = req.body.authToken

    if (!uid) {
        res.status(400).send({error : "Firebase id invalid."})
    }

    const decodedClaims = await firebaseAdmin.auth().verifyIdToken(authToken)

    if (uid != decodedClaims.uid){
        res.status(400).send({"error" : "uid and decoded uid is not same."})
    }

    const firebaseUser = await firebaseAdmin.auth().getUser(uid)
    const createLog = new Log({...req.body, "date" : Date.now()})
    await createLog.save()

    res.send({"success":true})



})

module.exports = router