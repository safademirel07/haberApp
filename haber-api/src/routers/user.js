const express = require("express")
const auth = require("../middleware/auth")
const User = require("../models/user")
const router = new express.Router()
const validator = require("validator")

const firebaseAdmin = require("../firebase/firebase")
const bcrypt = require("bcryptjs")



router.post("/users/register", async (req,res) => {

    User.findOne({ email : req.body.email}).then(user => {
        if (user) {
            return res.status(404).send({"error": "This is email is already in use."})
        }
        return;

    })

    if (!validator.isEmail(req.body.email)) {
        return res.status(404).send({"error": "Please enter a valid email address."})
    } 


    if (req.body.password != req.body.password2) {
        return res.status(400).send({"error": "Passwords doesnt match."})
    }

    const user = new User(req.body)

    try {


        firebaseAdmin.auth().createUser({
            email: req.body.email,
            password: req.body.password,
          })
            .then(async function(userRecord) {
              // See the UserRecord reference doc for the contents of userRecord.
              console.log('[Firebase] Successfully created new user:', userRecord.uid);

              user.firebaseUID = userRecord.uid

              await user.save()
              const token = await user.generateAuthToken()
      
              return res.status(201).send( { 
                  "_id" : user._id,
                  "name" : user.name,     
                  "profilePhoto" : user.profilePhoto,       
                  "email" : user.email,      
                  token 
              })


            })
            .catch(function(error) {
                return res.status(400).send({"error": "A Firebase eror happened."})
            });


        
    } catch (e) {
        console.log(e)
        return res.status(400).send({"error": "An unknown eror happened."})
    }

})

router.post("/users/profile_photo", auth.auth, async (req,res) => {
    try {
        const user = req.user;
        var imageUrl = req.query.image;

        if (imageUrl == undefined)
        {
            res.status(400).send({"error" : "Unable to change. Image not found."})
        }

        if (!user) {
            res.status(400).send({"error" : "Unable to change. User not found."})
        }

        if (!validator.isURL(imageUrl)) {
            res.status(400).send({"error" : "Unable to change. Not an image."})
        }

        var imageUrl = imageUrl.replace("https://firebasestorage.googleapis.com/v0/b/haberapp-54a0c.appspot.com/o/images/","https://firebasestorage.googleapis.com/v0/b/haberapp-54a0c.appspot.com/o/images%2F")
        

        user.profilePhoto = imageUrl
        user.save()


        var userObject = user.toJSON()
        delete userObject.favorites
        delete userObject.likes
        delete userObject.dislikes
        delete userObject.__v
        res.send(userObject)
    } catch (e) {
        console.log(e)
        res.status(400).send({"error" : "Unable to login."})
    }
})


router.post("/users/edit_profile", auth.auth, async (req,res) => {
    try {
        const user = req.user;
        var name = req.query.name;
        var email = req.query.email;

        if (!user) {
            res.status(400).send({"error" : "Unable to change. User not found."})
        }

        if (name == undefined || email == undefined)
        {
            res.status(400).send({"error" : "Unable to change. Undefined."})
        }


        if (!validator.isURL(email)) {
            res.status(400).send({"error" : "Unable to change. Not an email."})
        }


        user.name = name
        user.email = email
        user.save()

        var userObject = user.toJSON()
        delete userObject.favorites
        delete userObject.likes
        delete userObject.dislikes
        delete userObject.__v
        res.send(userObject)
    } catch (e) {
        console.log(e)
        res.status(400).send({"error" : "Unable to login."})
    }
})


router.post("/users/change_password", auth.auth, async (req,res) => {
    try {
        const user = req.user;
        var old_password = req.body.old_password;
        var new_password = req.body.new_password;
        var re_password = req.body.re_password;
        var uid = req.body.uid;

        if (!user) {
            res.status(400).send({"error" : "Kullanıcı bulunamadı."})
            return
        }

        if (old_password == undefined || new_password == undefined || re_password == undefined)
        {
            res.status(400).send({"error" : "Eksik bilgi."})
            return
        }

        const isMatch = await bcrypt.compare(old_password, user.password)

        if (!isMatch) {
            res.status(400).send({"error" : "Girdiğiniz eski şifre yanlış."})
            return
        }

        if (old_password == new_password ) {
            res.status(400).send({"error" : "Yeni şifren, eskisiyle aynı olamaz."})
            return

        }

        if (new_password.length < 6) {
            res.status(400).send({"error" : "Yeni şifre en az 6 karakter olmalı."})
            return
        }

        if (new_password != re_password) {
            res.status(400).send({"error" : "Yeni şifre ve tekrarı yanlış."})
            return
        }

        firebaseAdmin.auth().updateUser(uid,{
            password: new_password,
          })
            .then(async function(userRecord) {
              console.log('[Firebase] Password changed for user:', userRecord.uid);


              user.password = new_password
              user.tokens = []
              await user.save()
      
             const token = await user.generateAuthToken()
      
             res.send( { 
                "_id" : user._id,
                "profilePhoto" : user.profilePhoto,      
                "name" : user.name,      
                "email" : user.email,  
                token 
            })
      
            })
            .catch(function(error) {
                console.log("gelen error  " + error)
                return res.status(400).send({"error": "A Firebase eror happened."})
            });

    } catch (e) {
        console.log(e)
        res.status(400).send({"error" : "Unable to login."})
    }
})

router.post("/users/login", async (req,res) => {
    try {
        const user = await User.findByCredentials(req.body.email, req.body.password)
        
        const token = await user.generateAuthToken()

        res.send( { 
            "_id" : user._id,
            "profilePhoto" : user.profilePhoto,      
            "name" : user.name,      
            "email" : user.email,  
            token 
        }) 
    } catch (e) {
        console.log(e)
        res.status(400).send({"error" : "Unable to login."})
    }
})

router.post("/users/auth", auth.auth, async (req,res) => {
    return res.send({"message" : "Auth success"})

    
})


router.post("/users/logout", auth.auth, async (req,res) => {
    try {
        req.user.tokens = req.user.tokens.filter((token) => {
            return token.token != req. token
        })
        await req.user.save()
        res.send({"message" : "Logout successful"})
    } catch (e) { 
        res.status(500).send()
    }
})

router.post("/users/logoutAll", auth.auth, async (req,res) => {
    try {
        req.user.tokens = []
        await req.user.save()
        res.send({"message" : "Logout All successful"})
    } catch (e) {
        res.status(500).send(e)
    }
})
    
      
router.get("/users/me", auth.auth, async (req,res) => {
    const user = req.user.toJSON()
    delete user.favorites
    delete user.likes
    delete user.dislikes
    delete user.__v
    res.send(user)
})


router.patch("/users/me", auth.auth, async (req,res) => {
    const updates = Object.keys(req.body)
    const allowedUpdates = ["photoUrl"]
    const isValid = updates.every((update) => allowedUpdates.includes(update))

    if (!isValid) {
        return res.status(400).send({ error: "Invalid updates!"})
    }

    try {
        updates.forEach((update) => req.user[update] = req.body[update])
        await req.user.save()
        res.send(req.user)
    } catch(e) {
        res.status(400).send(e)
    }
}) 


router.delete("/users/me", auth.auth, async (req,res) => {
     try {
        await req.user.remove()
        res.send(req.user)
    } catch (e) {
        return res.status(500).send(e)
    }
})





module.exports = router