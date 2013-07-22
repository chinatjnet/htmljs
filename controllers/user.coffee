func_user = __F 'user'
func_card = __F 'card'
config = require './../config.coffee'
authorize=require("./../lib/sdk/authorize.js")
Sina=require("./../lib/sdk/sina.js")

md5 = require 'MD5'
module.exports.controllers = 
  "/login":
    get:(req,res,next)->
      res.locals.link = authorize.sina
        app_key:config.sdks.sina.app_key,
        redirect_uri:config.sdks.sina.redirect_uri
        client_id:config.sdks.sina.app_key
      res.render 'login.jade'
  "/sina_cb":
    get:(req,res,next)->
      code = req.query.code
      link = authorize.sina
        app_key:config.sdks.sina.app_key,
        redirect_uri:config.sdks.sina.redirect_uri
        client_id:config.sdks.sina.app_key
      _sina=new Sina(config.sdks.sina)
      if !code
        res.end '绑定错误:'+error.message+'，请<a href='+link+'>重新绑定</a>'
        return
      _sina.oauth.accesstoken code,(error,data)->
        if error 
          res.end '绑定错误:'+error.message+'，请<a href='+link+'>重新绑定</a>'
        else
          access_token = data.access_token
          func_user.getByWeiboId data.uid,(error,user)->
            if user
              user.updateAttributes
                weibo_token:access_token
              .success ()->
                res.cookie '_p', user.id+":"+md5(user.weibo_token), 
                  expires: new Date(Date.now() + 1000*60*60*24*7)
                  httpOnly: true
                  domain:"html-js.com"
                res.redirect '/user'
              .error (error)->
                res.end '绑定错误:'+error.message+'，请<a href='+link+'>重新绑定</a>'
            else
              _sina.users.show
                access_token:access_token
                uid:data.uid
                method:"get"
              ,(error,data)->
                if error 
                  res.end '绑定错误:'+error.message+'，请<a href='+link+'>重新绑定</a>'
                else
                  func_user.add {nick:data.screen_name,weibo_id:data.id,weibo_token:access_token,head_pic:data.profile_image_url},(error,user)->
                    if error
                      res.end '绑定错误:'+error.message+'，请<a href='+link+'>重新绑定</a>'
                    else
                      res.cookie '_p', user.id+":"+md5(user.weibo_token), 
                        expires: new Date(Date.now() + 1000*60*60*24*7)
                        httpOnly: true
                        domain:"html-js.com"
                      res.redirect '/user'
  "/connet-card":
    post:(req,res,next)->
      result = 
        success:0
      if !res.locals.user
        result.info = "登录失效，请重新登录"
        res.send result
        return
      if res.locals.card
        result.info = "您已经关联过名片！"
        res.send result
        return
      func_user.connectCard res.locals.user.id,req.body.id,(error,user)->
        if error 
          result.info = error.message
        else
          result.success= 1
        res.send result
        if !error
          sina=new Sina(config.sdks.sina)
          sina.statuses.update 
            access_token:res.locals.user.weibo_token
            status:"我在@前端乱炖 的《前端花名册》认领了我的名片，这里是我的名片，欢迎收藏：http://www.html-js.com/user/"+res.locals.user.id
  "/update":
    post:(req,res,next)->
      result = 
        success:0
      func_card.update res.locals.card.id,req.body,(error,card)->
        if error
          result.info = error.message
        else
          result.success = 1
        res.send result
  "/":
    get:(req,res,next)->
      res.render 'me.jade'
  "/:id":
    get:(req,res,next)->
      res.locals.md5 = md5
      func_user.getById req.params.id,(error,user)->
        if error then next error
        else
          if not user then next new Error '不存在的用户'
          else
            res.locals.p_user = user
            if user.card_id
              res.redirect '/card/'+user.card_id
            else
              res.render 'p.jade'
    
module.exports.filters = 
  "/":
    get:['checkLogin',"checkCard"]
  "/:id":
    get:['checkLogin']
  "/connet-card":
    post:['checkLogin',"checkCard"]
  "/update":
    post:['checkLogin',"checkCard"]