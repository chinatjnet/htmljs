func_article = __F 'article'
func_info = __F 'info'
func_timeline = __F 'timeline'
module.exports.controllers = 
  "/":
    get:(req,res,next)->
      res.render 'reads.jade'

  "/me":
    get:(req,res,next)->
      res.render 'my-reads.jade'
  "/:id":
    "get":(req,res,next)->
      
      func_article.getVisitors req.params.id,(error,visitors)->
        if error then next error
        else 
          res.locals.visitors = visitors
          func_article.getById req.params.id,(error,article)->
            if error then next error
            else if not article then next new Error '不存在的阅读'
            else
              
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
  '/':
    get:['freshLogin','read/all-reads']
  "/me":
    get:['checkLogin','read/my-reads']
    post:[]
  "/:id":
    get:['freshLogin']
  "/add/recommend":
    get:['checkLogin',"checkCard"]
    post:['checkLogin',"checkCard"]