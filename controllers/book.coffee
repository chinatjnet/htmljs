func_book = __F 'book'
request = require 'request'
config = require './../config.coffee'
Sina=require("./../lib/sdk/sina.js")
module.exports.controllers = 
  "/":
    get:(req,res,next)->

      res.render 'book/books.jade'
  "/add":
    get:(req,res,next)->
      res.render 'book/add.jade'
    post:(req,res,next)->
      req.body.pub_user_id = res.locals.user.id
      req.body.pub_user_nick = res.locals.user.nick

      func_book.add req.body,(error,callback)->
        if error then next error
        else
          res.redirect '/book'
  "/:id/buy":
    get:(req,res,next)->
      func_book.sellToUser req.params.id,res.locals.user,(error,book)->
        if error then next error
        else
          sina=new Sina(config.sdks.sina)
          sina.statuses.update 
            access_token:res.locals.user.weibo_token
            status:"我在@前端乱炖 免费获得了一本《"+book.title+"》,名额有限，速度来抢！http://www.html-js.com/book"
          res.redirect 'back'
  "/:id/del":
    get:(req,res,next)->
      func_book.getById req.params.id,(error,book)->
        if error then next error
        else if book
          if res.locals.user.id == book.pub_user_id
            book.destroy().success ()->
              res.redirect 'back'
            .error (e)->
              next(e)
          else
            next new Error '没有权限'
        else
          next new Error '不存在的书籍'
      
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
    get:['freshLogin','checkCard','book/all-books','book/my-book','book/my-pub-book']
  "/add":
    post:['checkLogin','book/check-add']
  "/:id/del":
    get:['checkLogin']
  "/:id/buy":
    get:['checkLogin','checkCard','book/check-user']