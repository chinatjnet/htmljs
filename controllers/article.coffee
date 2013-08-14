func_user = __F 'user'
func_article = __F 'article'
config = require './../config.coffee'
authorize=require("./../lib/sdk/authorize.js");
md5 = require 'MD5'
Sina=require("./../lib/sdk/sina.js")
sina=new Sina(config.sdks.sina)
pagedown = require("pagedown")
safeConverter = pagedown.getSanitizingConverter()
read = require("readability")
request = require 'request'
rss = require 'rss'
module.exports.controllers = 
  "/":
    "get":(req,res,next)->
      condition = 
        is_publish:1
        is_yuanchuang:1
      if req.query.filter
        condition=condition||{}
        req.query.filter.split(":").forEach (f)->
          kv = f.split '|'
          if kv.length
            condition[kv[0]]=kv[1]
            res.locals["filter_"+kv[0]]=kv[1]
      res.locals.types=
        1:"原创"
        2:"精品推荐"
        3:"实例学习"

      func_article.count condition,(error,count)->
        if error then next error
        else
          res.locals.total=count
          res.locals.totalPage=Math.ceil(count/20)
          res.locals.page = (req.query.page||1)
          func_article.getAll res.locals.page,20,condition,(error,articles)->
            if error then next error
            else
              res.locals.articles = articles
              res.render 'articles.jade'
  
  "/add/recommend":
    "get":(req,res,next)->
      res.render 'add-recommend.jade'
    "post":(req,res,next)->
      
      data = 
        html:req.body.html
        title:req.body.title
        type:2
        quote_url:req.body.quote_url
        user_id:res.locals.user.id
        user_nick:res.locals.user.nick
        user_headpic:res.locals.user.head_pic
        publish_time:new Date().getTime()/1000
      result = 
        success:0
      func_article.add data,(error,article)->
        if error 
          result.info = error.message
        else
          result.success = 1
        res.send result
  "/online_to_local":
    "post":(req,res,next)->
      url = req.body.url.replace(/#.*$/,"") #替换掉符号后的字符
      result = 
        success:0
        info:""
      #先查找数据中是否已经存在
      func_article.getByUrl url,(error,art)->
        if art
          result.data = art
          result.success = 1
          res.send result
        else
          request.get url,(e,s,entry)->
            console.log s 
            if e 
              result.info = e.message
              res.send result
            else
              read.parse entry,"",(parseResult)->
                titlematch = entry.match(/<title>(.*?)<\/title>/)
                t = ""
                if titlematch then t=titlematch[1] 
                result.data= 
                  url:url
                  title:(parseResult.title||t).replace(/^\s*|\s*$/,"")
                  content:parseResult.content
                  desc:parseResult.desc
                  real_url:s.request.href
                  is_publish:0
                result.success = 1
                result.is_realtime = 1 #表示是实时抓取而不是从数据库提取的
                res.send result
  "/add":
    "get":(req,res,next)->
      
      res.render 'add-article.jade'
    "post":(req,res,next)->
      
      data = 
        md:req.body.md
        html:safeConverter.makeHtml req.body.md
        title:req.body.title
        type:req.body.type
        user_id:res.locals.user.id
        user_nick:res.locals.user.nick
        user_headpic:res.locals.user.head_pic
        publish_time:new Date().getTime()/1000
        is_publish:0
      result = 
        success:0
      func_article.add data,(error,article)->
        if error 
          result.info = error.message
        else
          result.success = 1
        res.send result
  "/:id":
    "get":(req,res,next)->
      func_article.getVisitors req.params.id,(error,visitors)->
        if error then next error
        else
          res.locals.visitors = visitors
          func_article.getById req.params.id,(error,article)->
            if error then next error
            else
              res.locals.article = article
              func_article.addVisit req.params.id,res.locals.user||null
              res.render 'article.jade'
module.exports.filters = 
  "/add":
    get:['checkLogin',"checkCard"]
    post:['checkLogin',"checkCard"]
  "/add/recommend":
    get:['checkLogin',"checkCard"]
    post:['checkLogin',"checkCard"]
  "/":
    get:['getRecent']
  "/:id":
    get:['getRecent']