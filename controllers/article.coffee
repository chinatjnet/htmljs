func_user = __F 'user'
func_article = __F 'article'
func_info = __F 'info'
func_timeline = __F 'timeline'
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
          func_timeline.add 
            who_id:res.locals.user.id
            who_headpic:res.locals.user.head_pic
            who_nick:res.locals.user.nick
            target_url:"/read/"+article.id
            target_name:article.title
            action:"收藏了文章："
            desc:article.html.replace(/<p>(.*?)<\/p>/g,"$1\n").replace(/<[^>]*?>/g,"").substr(0,300).replace(/([^\n])\n+([^\n])/g,"$1<br/>$2")
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
      html = safeConverter.makeHtml req.body.md
      match = html.match(/<img[^>]+?src="([^"]+?)"/)
      data = 
        md:req.body.md
        html:html
        title:req.body.title
        type:req.body.type
        user_id:res.locals.user.id
        user_nick:res.locals.user.nick
        user_headpic:res.locals.user.head_pic
        publish_time:new Date().getTime()/1000
        is_yuanchuang:1
        is_publish:if res.locals.user.is_admin then 1 else 0
        main_pic:if match then match[1] else null
      result = 
        success:0
      func_article.add data,(error,article)->
        if error 
          result.info = error.message
        else
          result.success = 1
          func_timeline.add 
            who_id:res.locals.user.id
            who_headpic:res.locals.user.head_pic
            who_nick:res.locals.user.nick
            target_url:"/article/"+article.id
            target_name:article.title
            action:"发表了专栏文章："
            desc:(if article.main_pic then "<img src='"+article.main_pic+"' class='main_pic'/>" else "")+article.html.replace(/<p>(.*?)<\/p>/g,"$1\n").replace(/<[^>]*?>/g,"").substr(0,300)..replace(/([^\n])\n+([^\n])/g,"$1<br/>$2")
        res.send result
  "/:id":
    "get":(req,res,next)->

      func_article.getVisitors req.params.id,(error,visitors)->
        if error then next error
        else
          res.locals.visitors = visitors
          func_article.getById req.params.id,(error,article)->
            if error then next error
            else if not article then next new Error '不存在的文章'
            else
              if article.user_id && res.locals.user
                func_info.add 
                  target_user_id:article.user_id
                  type:1
                  source_user_id:res.locals.user.id
                  source_user_nick:res.locals.user.nick
                  time:new Date()
                  target_path:req.originalUrl
                  target_path_name:"原创文章:"+article.title
                ,()->
                  console.log 'success'
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
    get:['freshLogin','getRecent','get_infos']
  "/:id":
    get:['freshLogin','getRecent','get_infos']