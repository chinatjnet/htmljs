func_user = __F 'user'
func_card = __F 'card'
func_bao = __F 'bao'
func_article = __F 'article'
config = require './../config.coffee'
authorize=require("./../lib/sdk/authorize.js");
md5 = require 'MD5'
Sina=require("./../lib/sdk/sina.js")
RSS=require 'rss'
sina=new Sina(config.sdks.sina)
moment = require 'moment'
path = require 'path'
fs = require 'fs'
UPYun=require("./../../../lib/upyun.js").UPYun
module.exports.controllers = 
  "/":
    get:(req,res,next)->
      res.redirect '/article'
  "/rss":
    "get":(req,res,next)->
      feed = new RSS
        title: "前端乱炖，前端人才资源学习资源集散地",
        description: "前端乱炖，前端人才资源学习资源集散地",
        feed_url: 'http://www.html-js.com/rss.xml',
        site_url: 'http://www.html-js.com',
        image_url: 'http://www.html-js.com/icon.png',
        author: "芋头"
      func_article.getAll 1,20,null,(error,articles)->
        if error then next error
        else
          articles.forEach (article)->
            feed.item
              title: article.title,
              description: article.html,
              url: 'http://www.html-js.com/article/'+article.id
              author: article.user_nick
              date: article.publish_time*1000
          res.end feed.xml()
  "/rss.xml":
    "get":(req,res,next)->
      feed = new RSS
        title: "前端乱炖，前端人才资源学习资源集散地",
        description: "前端乱炖，前端人才资源学习资源集散地",
        feed_url: 'http://www.html-js.com/rss.xml',
        site_url: 'http://www.html-js.com',
        image_url: 'http://www.html-js.com/icon.png',
        author: "芋头"
      func_article.getAll 1,20,null,(error,articles)->
        if error then next error
        else
          articles.forEach (article)->
            feed.item
              title: article.title,
              description: article.html,
              url: 'http://www.html-js.com/article/'+article.id
              author: article.user_nick
              date: article.publish_time*1000
          res.end feed.xml()

  "/articles":
    "get":(req,res,next)->
  "/article/add":
    "get":(req,res,next)->
        
      res.render 'add-article.jade'
  "/cards":
    "get":(req,res,next)->
      res.locals.md5 = md5
      res.locals.login = authorize.sina
        app_key:config.sdks.sina.app_key,
        redirect_uri:config.sdks.sina.redirect_uri
      condition = null
      if req.query.q
        condition = condition ||{}
        condition = "cards.name like '%"+req.query.q+"%' or cards.nick like '%"+req.query.q+"%'"
        res.locals.q = req.query.q
      if req.query.filter
        condition=condition||{}
        req.query.filter.split(":").forEach (f)->
          kv = f.split '|'
          if kv.length
            condition[kv[0]]=kv[1]
            res.locals["filter_"+kv[0]]=kv[1]
      func_card.count condition,(error,count)->
        if error then next error
        else
          res.locals.total=count
          res.locals.totalPage=Math.ceil(count/20)
          res.locals.page = (req.query.page||1)
          func_card.getAll res.locals.page,20,condition,(error,cards)->
            if error then next error
            else
              res.locals.cards = cards
              res.render 'cards.jade'
  "/add-card":
    get:(req,res,next)->
      if res.locals.user
        sina.users.show
          access_token:res.locals.user.weibo_token
          uid:res.locals.user.weibo_id
          method:"get"
        ,(error,data)->
          if !error
            res.locals.weibo_info = data
            res.render 'add-card.jade'
      else
        res.render 'add-card.jade'
    post:(req,res,next)->
      if res.locals.user.card_id
        next new Error '您已经拥有一个名片！'
        return
      func_card.add req.body,(error,card)->
        if error then next error
        else
          sina.statuses.update 
            access_token:res.locals.user.weibo_token
            status:"我在@前端乱炖 的《前端花名册》添加了我的名片，欢迎收藏：http://www.html-js.com/user/"+res.locals.user.id
          func_user.connectCard res.locals.user.id,card.id,(error)->
            if error then next error
            else
              res.redirect '/user'
  "/edit-card":
    get:(req,res,next)-> 
      res.render 'edit-card.jade'
    post:(req,res,next)->
      func_card.update req.body.id,req.body,(error,card)->
        if error then next error
        else
          res.redirect '/user'
  "/card/:id":
    get:(req,res,next)->
      res.locals.md5 = md5
      func_card.getById req.params.id,(error,card)->
        if error then next error
        else
          func_card.getVisitors card.id,(error,visitors)->
            if error then next error
            else
              res.locals.visitors = visitors
              func_card.addVisit card.id,res.locals.user||null
              if card then res.locals.card = card
              if card.user_id
                func_article.getByUserIdAndType (card.user_id||-1),1,(error,articles)->
                  if error then next error
                  else
                    res.locals.articles = articles
                    res.render 'p.jade'
              else
                res.render 'p.jade'
  "/card/:id/bao":
    post:(req,res,next)->
      data = 
        pic:req.body.pic
        content:req.body.content
        user_id:res.locals.user.id
        user_headpic:res.locals.user.head_pic
        user_nick:res.locals.user.nick
        card_id:req.params.id
      func_bao.add data,(error,bao)->
        if error then next error
        else
          func_card.getById req.params.id,(error,card)->
            if not error
              if req.body.pic
                sina.statuses.upload 
                  access_token:res.locals.user.weibo_token
                  pic:config.base_path+req.body.pic
                  status:"我在@前端乱炖 爆料了大神 "+card.nick+" 的真像，求围观，求吐槽！！http://www.html-js.com/card/"+req.params.id
              else
                sina.statuses.update 
                  access_token:res.locals.user.weibo_token
                  status:"我在@前端乱炖 爆料了大神 "+card.nick+" 的八卦，求围观，求吐槽，求同扒！！http://www.html-js.com/card/"+req.params.id
            res.redirect 'back'
  "/upload":
    "post":(req,res,next)->
      result = 
        success:0
        info:""
      pack = req.files['pic']
      if pack && (pack.type == 'image/jpeg'||pack.type == "image/jpg"||pack.type=="image/png")
        sourcePath = pack.path
        targetPath = config.upload_path+(new Date()).getTime()+"-"+pack.name
        fs.rename sourcePath, targetPath, (err) ->
          if err
            result.info = err.message
            res.send result
            return
          else
            result.success = 1
            result.data = 
              filename:targetPath.replace(config.upload_path,"")
          upyun = new UPYun(config.upyun_bucketname, config.upyun_username, config.upyun_password)
          fileContent = fs.readFileSync(targetPath)
          md5Str = md5(fileContent)
          upyun.setContentMD5(md5Str)
          upyun.setFileSecret('bac')
          upyun.writeFile '/'+filename, fileContent, false,(error, data)->
            if !error
              result.success=1
              result.data.url = "http://htmljs.b0.upaiyun.com/"+filename
            else
              result.info=error.message
            #res.end(JSON.stringify(result))
          res.send result
      else
        result.info = "错误的图片文件"
        res.send result  
  "/test":
    "get":(req,res,next)->
      res.render 'test.jade'
module.exports.filters = 
  "/article/add":
    get:['checkLogin',"checkCard"]
  "/cards":
    get:['freshLogin',"checkCard","card_hot","card_recent"]
  "/card/:id":
    get:['freshLogin','getBao']
  "/add-card":
    get:['checkLogin',"checkCard"]
    post:['checkLogin']
  "/edit-card":
    get:['checkLogin',"checkCard"]
  "/card/:id/bao":
    post:['checkLogin',"checkCard"]