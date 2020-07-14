const express = require("express")
const router = new express.Router()
const https = require('https');
const { Server } = require("http");


var parseString = require('xml2js').parseString;

function xmlToJson(url, callback) {
    var req = https.get(url, function(res) {
      var xml = '';
      
      res.on('data', function(chunk) {
        xml += chunk;
      });
  
      res.on('error', function(e) {
        callback(e, null);
      }); 
  
      res.on('timeout', function(e) {
        callback(e, null);
      }); 
  
      res.on('end', function() {
        parseString(xml, function(err, result) {
          callback(null, result);
        });
      });
    });
  }


router.get("/parser/sabah", async (req,res) => {
    const url = "https://www.sabah.com.tr/rss/otomobil.xml";
    xmlToJson(url, function(err, data) {
        if (err) {
          return console.err(err);
        }

        const json = JSON.parse(JSON.stringify(data));


        var items = json.rss.channel[0].item

        var data = []

        items.forEach(item => {


          if (item.enclosure == undefined)
          {
            return

          }


          data.push({"title" : item.title[0], "image" : item.enclosure[0]["$"].url})

          
        });

        res.send(data)
    
      }
    )
})


module.exports = router