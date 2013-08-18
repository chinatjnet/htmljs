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
  "/isbn_to_info":
    "get":(req,res,next)->
      result = 
        success :0
        info:""
      request.get {url:'https://api.douban.com/v2/book/isbn/'+req.query.isbn}, (e, r, body)->
        if e 
          result.info = e.message
        else
          result.success = 1
          result.data = JSON.parse body
        res.send result
module.exports.filters = 
  "/":
    get:['freshLogin','checkCard','book/all-books','book/my-book']
  "/add":
    post:['checkAdmin']
  "/:id/buy":
    get:['checkLogin','checkCard','book/check-user']