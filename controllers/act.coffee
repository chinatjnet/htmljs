func_act = __F 'act'
config = require './../config.coffee'

Sina=require("./../lib/sdk/sina.js")
moment =require 'moment'
module.exports.controllers = 
  "/":
    get:(req,res,next)->
      page = req.params.page || 1
      count = 20
      func_act.getAll page,count,{is_publish:1},(error,acts)->
        res.locals.acts = acts
        res.render 'act/index.jade'

  "/add":
    get:(req,res,next)->
      res.render 'act/add.jade'
    post:(req,res,next)->
      func_act.add req.body,(error,act)->
        if error then next error
        else
          res.redirect '/act'
  "/:id/edit":
    get:(req,res,next)->
      func_act.getById req.params.id,(error,act)->
        if error then next error
        else
          res.locals.act = act
          res.render 'act/add.jade'
    post:(req,res,next)->
      func_act.update req.params.id,req.body,(error,act)->
        if error then next error
        else
          res.redirect '/act'
  "/:id":
    get:(req,res,next)->
      func_act.getById req.params.id,(error,act)->
        if error then next error
        else
          res.locals.act = act
          func_act.addCount req.params.id,"visit_count",(error)->
            
          func_act.getAllJoiners req.params.id,(error,joiners)->
            res.locals.joiners = joiners ||[]
            res.render 'act/act.jade'
  "/:id/join":
    post:(req,res,next)->

      result = 
        success:0
      if !res.locals.card 
        result.info = '必须添加花名册并填写真实信息后才能报名，谢谢配合！'
        result.code = 101
        res.send result
        return
      else if not /[0-9]{11}/.test res.locals.card.tel
        result.info = '必须填写有效的手机号后才能报名，谢谢配合！'
        result.code = 102
        res.send result
        return
      func_act.addJoiner req.params.id,res.locals.user,(error,joiner)->
        if error 
          result.info = error.message
          res.send result
        else
          func_act.getById req.params.id,(error,act)->
            if not error
              sina=new Sina(config.sdks.sina)
              sina.statuses.update 
                access_token:res.locals.user.weibo_token
                status:"我在@前端乱炖 报名了【"+act.title+"】的活动，活动时间："+moment(act.time.getTime()-8000*60*60).format("LLL")+"，欢迎关注：http://www.html-js.com/act/"+req.params.id
          
          result.success = 1
          result.data = joiner
          res.send result
module.exports.filters = 
  "/":
    get:['freshLogin']
  "/:id":
    get:['freshLogin','act/comments']
  "/add":
    get:['checkLogin','checkAdmin']
    post:['checkLogin','checkAdmin']
  "/:id/edit":
    get:['checkLogin','checkAdmin']
    post:['checkLogin','checkAdmin']
  "/:id/join":
    post:['checkLoginJson','checkCard']