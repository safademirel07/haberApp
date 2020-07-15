const express = require("express")
const router = new express.Router()
const https = require('https');
const { Server } = require("http");
var striptags = require('striptags');
const request = require('request');
const fetch = require("node-fetch");

const cheerio = require('cheerio');

const constants = require('../others/constants')

const News = require("../models/news");
const { json } = require("body-parser");


var parseString = require('xml2js').parseString;

function parseXml(body) {
  var parsed;
  parseString(body, function(err, result) {
   if (err) { throw err; }
   else { parsed = result; }
  });

  return parsed;
 }

router.get("/parser/sabah", async (req,res) => {
    const url = constants.sabahRSS;

    const fetchXML = await fetch(url)
    const dataXML = await fetchXML.text();

    const parsedXML = await parseXml(dataXML);

      const jsonNews = JSON.parse(JSON.stringify(parsedXML));
      var allNews = jsonNews.rss.channel[0].item

      var data = []

       for await (const item of allNews)
      {
        const newsDB = await News.findOne({"link" : item.link[0]})

        var link, title, description, body, date, image

        if (newsDB)
        {
          link = newsDB.link 
          title = newsDB.title 
          description = newsDB.description 
          body = newsDB.body 
          date = newsDB.date 
          image = newsDB.image
        } else {

          if (item.enclosure == undefined)
          {
            continue
  
          }

          const responseHtml = await fetch(item.link[0]);
          const dataHtml = await responseHtml.text();
          const $ = cheerio.load(dataHtml,  {xmlMode: true});
          const onlyJson = $('[type="application/ld+json"]')

          console.log(item.title[0] + " created.")
        
          const createNews = new News({
            title : item.title[0],
            description : striptags(item.description[0],[], ' '),
            body : JSON.parse(onlyJson.get()[0].children[0].data).articleBody.trim(),
            date : item.pubDate[0],
            link : item.link[0],
            image : item.enclosure[0]["$"].url,
          })
  
          createNews.save()

          link = createNews.link 
          title = createNews.title 
          description = createNews.description 
          body = createNews.body 
          date = createNews.date 
          image = createNews.image


        }
        data.push({"link" : link,"title" : title, "description" : description,"body": body, "date " : date , "image" : image})

      }



      res.send(data)

    });

router.get("/parser/cnn", async (req,res) => {
      const url = constants.cnnRSS;
  
      const fetchXML = await fetch(url)
      const dataXML = await fetchXML.text();
  
      const parsedXML = await parseXml(dataXML);
  
        const jsonNews = JSON.parse(JSON.stringify(parsedXML));

        console.log(jsonNews)

        
        var allNews = jsonNews.rss.channel[0].item
  
        var data = []
  
         for await (const item of allNews)
        {
          const newsDB = await News.findOne({"link" : item.link[0]})
  
          var link, title, description, body, date, image
  
          if (newsDB)
          {
            link = newsDB.link 
            title = newsDB.title 
            description = newsDB.description 
            body = newsDB.body 
            date = newsDB.date 
            image = newsDB.image
          } else {
  
            if (item.image == undefined)
            {
              continue
    
            }
  
            const responseHtml = await fetch(item.link[0]);
            const dataHtml = await responseHtml.text();
            const $ = cheerio.load(dataHtml,  {xmlMode: true});
            const onlyJson = $('[type="application/ld+json"]')

  
            console.log(item.title[0] + " created.")
          
            const createNews = new News({
              title : item.title[0],
              description : striptags(item.description[0],[], ' '),
              body : JSON.parse(onlyJson.get()[1].children[0].data).articleBody.trim(),
              date : item.pubDate[0],
              link : item.link[0],
              image : item.image[0],
            })

            console.log(createNews)
    
            createNews.save()
  
            link = createNews.link 
            title = createNews.title 
            description = createNews.description 
            body = createNews.body 
            date = createNews.date 
            image = createNews.image
  
  
          }
          data.push({"link" : link,"title" : title, "description" : description,"body": body, "date " : date , "image" : image})
  
        }
        res.send(data)
      });



//Alinti yapilan yerlerde çalışmıyor. &quot lar " olarak gelince json olarak parse edilmesini bozuyor. Türkçe karakterlerde sorun olabiliyor..
router.get("/parser/haberturk", async (req,res) => {
        const url = constants.haberturkRSS;
    
        const fetchXML = await fetch(url)
        const dataXML = await fetchXML.text();
    
        const parsedXML = await parseXml(dataXML);
        
    
          const jsonNews = JSON.parse(JSON.stringify(parsedXML));
          var allNews = jsonNews.rss.channel[0].item
    
          var data = []
    
           for await (const item of allNews)
          {
            const newsDB = await News.findOne({"link" : item.link[0]})
    
            var link, title, description, body, date, image
    
            if (newsDB)
            {
              link = newsDB.link 
              title = newsDB.title 
              description = newsDB.description 
              body = newsDB.body 
              date = newsDB.date 
              image = newsDB.image
            } else {
    
              if (item.enclosure == undefined)
              {
                continue
      
              }
    
              const responseHtml = await fetch(item.link[0]);
              const dataHtml = await responseHtml.text();
              const $ = cheerio.load(dataHtml,  {xmlMode: true});
              const onlyJson = $('[type="application/ld+json"]')


              
    
              
              try {
                const createNews = new News({
                  title : item.title[0],
                  description : striptags(item.description[0],[], ' '),
                  body :JSON.parse(onlyJson.get()[2].children[0].data).articleBody.trim(),
                  date : item.pubDate[0],
                  link : item.link[0],
                  image : item.enclosure[0]["$"].url,
                })

                createNews.save()
    
                link = createNews.link 
                title = createNews.title 
                description = createNews.description 
                body = createNews.body 
                date = createNews.date 
                image = createNews.image
                console.log(item.title[0] + " created.")


              } catch (e) {
                console.log("error ne?" + e)
                console.log(item.title[0] + " couldn't created.")

                continue
              }
            
            }
            data.push({"link" : link,"title" : title, "description" : description.trim(),"body": body, "date " : date , "image" : image})
    
          }
    
    
    
          res.send(data)
    
        });     


 
router.get("/parser/milliyet", async (req,res) => {
  const url = constants.milliyetRSS;

  const fetchXML = await fetch(url)
  const dataXML = await fetchXML.text();

  const parsedXML = await parseXml(dataXML);

    const jsonNews = JSON.parse(JSON.stringify(parsedXML));
    var allNews = jsonNews.rss.channel[0].item

    var data = []

     for await (const item of allNews)
     
    {
      const itemLink =  item["atom:link"][0]["$"]["href"]


      const newsDB = await News.findOne({"link" : itemLink})

      var link, title, description, body, date, image

      if (newsDB)
      {
        link = newsDB.link 
        title = newsDB.title 
        description = newsDB.description 
        body = newsDB.body 
        date = newsDB.date 
        image = newsDB.image
      } else {

        const responseHtml = await fetch(itemLink);
        const dataHtml = await responseHtml.text();
        const $ = cheerio.load(dataHtml,  {xmlMode: true});
        const onlyJson = $('[type="application/ld+json"]')

        const imageHtml = cheerio.load(item.description[0],  {xmlMode: true})
        const itemImage = imageHtml('img').attr('src')
  

        console.log(item.title[0] + " created.")
      
        const createNews = new News({
          title : item.title[0],
          description : striptags(item.description[0],[], ' '),
          body : JSON.parse(onlyJson.get()[0].children[0].data).articleBody.trim(),
          date : item.pubDate[0],
          link : itemLink,
          image : itemImage,
        })

        console.log(createNews)

        createNews.save()

        link = createNews.link 
        title = createNews.title 
        description = createNews.description 
        body = createNews.body 
        date = createNews.date 
        image = createNews.image

        


      }
      data.push({"link" : link,"title" : title, "description" : description,"body": body, "date " : date , "image" : image})

    }



    res.send(data)

  });
     

module.exports = router