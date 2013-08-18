func_book = __F 'book'
request = require 'request'
module.exports.controllers = 
  "/":
    get:(req,res,next)->

      res.render 'book/books.jade'
  "/add":
    get:(req,res,next)->
      res.render 'book/add.jade'
    post:(req,res,next)->
      func_book.add req.body,(error,callback)->
        if error then next error
        else
          res.redirect '/book'
  "/:id/buy":
    get:(req,res,next)->
      func_book.sellToUser req.params.id,res.locals.user,(error,book)->
        if error then next error
        else
          res.redirect 'back'
module.exports.filters = 
  "/":
    get:['freshLogin','checkCard','book/all-books','book/my-book']
  "/:id/buy":
    get:['checkLogin','checkCard','book/check-user']