func_article = __F 'article'
func_info = __F 'info'
func_timeline = __F 'timeline'
module.exports.controllers = 
  "/":
    get:(req,res,next)->
      page = req.query.page || 1
      count = 20
      condition = {is_yuanchuang:0}
      res.locals.cat = "all"
      func_article.count condition,(error,total)->
        if error then next error
        else
          res.locals.total=total
          res.locals.totalPage=Math.ceil(total/count)
          res.locals.page = (req.query.page||1)
          func_article.getAll page,count,condition,(error,articles)->
            if error then next error
            else
              res.locals.articles = articles
              res.render 'reads.jade'
    post:(req,res,next)->
  "/me":
    get:(req,res,next)->
      page = req.query.page || 1
      count = 30
      condition = {is_yuanchuang:0,user_id:res.locals.user.id}
      res.locals.cat = "me"
      func_article.count condition,(error,count)->
        if error then next error
        else
          res.locals.total=count
          res.locals.totalPage=Math.ceil(count/20)
          res.locals.page = (req.query.page||1)
          func_article.getAll page,count,condition,(error,articles)->
            if error then next error
            else
              res.locals.articles = articles
              res.render 'reads.jade'
  "/:id":
    "get":(req,res,next)->
      
      func_article.getVisitors req.params.id,(error,visitors)->
        if error then next error
        else
          res.locals.visitors = visitors
          func_article.getById req.params.id,(error,article)->
            if article.user_id && res.locals.user
              func_info.add 
                target_user_id:article.user_id
                type:1
                source_user_id:res.locals.user.id
                source_user_nick:res.locals.user.nick
                time:new Date()
                target_path:req.originalUrl
                target_path_name:" 收藏的文章:"+article.title
              ,()->
                console.log 'success'
            res.locals.article = article
            func_article.addVisit req.params.id,res.locals.user||null
            res.render 'read.jade'
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
            desc:article.html.replace(/<p>(.*?)<\/p>/g,"$1\n").replace(/<[^>]*?>/g,"").substr(0,300).replace(/[^\n]\n+[^\n]/g,"<br/>")
        res.send result
module.exports.filters = 
  "/me":
    get:['checkLogin','checkCard']
    post:[]
  "/:id":
    get:['freshLogin']
  "/add/recommend":
    get:['checkLogin',"checkCard"]
    post:['checkLogin',"checkCard"]