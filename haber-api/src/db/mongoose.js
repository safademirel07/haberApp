const mongoose = require("mongoose")


try {
    //mongoose.connect('mongodb://localhost:27017/news_api',
    //mongodb+srv://***REMOVED***@cluster0.ihwoe.gcp.mongodb.net/news_api?retryWrites=true&w=majority
    
    mongoose.connect('mongodb+srv://***REMOVED***@cluster0.ihwoe.gcp.mongodb.net/news_api?retryWrites=true&w=majority',  {
        useNewUrlParser : true,
        useCreateIndex : true}) 
} catch (e)
{
    console.log(e);
}
