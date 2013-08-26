func_bao_comment = __F 'bao_comment'
func_bao = __F 'bao'
jade = require 'jade'
path = require 'path'
config = require './../config.coffee'
Sina=require("./../lib/sdk/sina.js")
sina=new Sina(config.sdks.sina)
module.exports.controllers = 
  "/add":
    "post":(req,res,next)->
      data = 
        content:req.body.content
        user_id:res.locals.user.id
        user_headpic:res.locals.user.head_pic
        user_nick:res.locals.user.nick
        card_id:req.params.id
        bao_id:req.body.bao_id
      result = 
        success:0
        info:''
      func_bao.addComment req.body.bao_id,req.body.content,res.locals.user,(error,bao)->
        if error 
          result.info = error.message
        else
          result.success = 1
          result.data = bao
        res.send result
  "/zan/:id":
    post:(req,res,next)->
      result = 
        success:0
        info:''
      func_bao.addZan req.params.id,(error,bao)->
        if error 
          result.info = error.message
        else
          result.success = 1
          result.data = bao
        res.send result
  "/list/:id":
    get:(req,res,next)->
      result = 
        success:0
        info:''
      func_bao_comment.getAll 1,20,{bao_id:req.params.id},(error,comments)->
        if error 
          result.info = error.message
          res.send result
          return
        else
          jade.renderFile path.join(__dirname,'../','views/bao_comment_item.jade'), { pretty: false, locals: {comments:comments,moment:(require 'moment')} }, (err, html)->
            if err 
              result.info = err.message
            else
              result.success = 1
              result.data = html
            res.send result
      
module.exports.filters = 
  "/add":
    post:['checkLogin',"checkCard"]
  "/list/:id":
    get:['checkLogin',"checkCard"]