const express = require("express")
const router = new express.Router()
const mongoose = require("mongoose")
const Log = require("../models/log")
const firebaseAdmin = require("../firebase/firebase")

router.get("/landing/get", async(req,res) => {

    var data = [
        {
            type : 1,
            title: 'En Son Haberler',
            description: 'Senin seçtiğinden sitelerden en son haberleri öğren.',
            titleColor: "0xFF000000",
            descripColor: "0xFF929794",
            imagePath: 'assets/images/vector_2.png',
        },
        {
            type : 1,
            title: 'Fikrini Belirt',
            description: 'Haberlere yorum yaparak fikrini belirt.',
            titleColor: "0xFF000000",
            descripColor: "0xFF929794",
            imagePath: 'assets/images/vector_5.png',
        },
        {
            type : 1,
            title: 'Üyelik',
            description: 'Üye olarak haberlere yorum yap, beğen, favorine ekle!',
            titleColor: "0xFF000000",
            descripColor: "0xFF929794",
            imagePath: 'assets/images/vector_4.png',
        }
    ]

    res.send(data)



})

module.exports = router