const mongoose = require("mongoose")


try {
    mongoose.connect('mongodb://localhost:27017/news_api', {
        useNewUrlParser : true,
        useCreateIndex : true
    }) 
} catch (e)
{
    console.log(e);
}
