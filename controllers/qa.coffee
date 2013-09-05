func_question = __F 'question'
func_timeline = __F 'timeline'
func_answer = __F 'answer'
pagedown = require("pagedown")
safeConverter = pagedown.getSanitizingConverter()
moment = require 'moment'
module.exports.controllers = 
  "/":
    get:(req,res,next)->
      
      res.render 'qa/index.jade'
  "/add":
    get:(req,res,next)->
      res.render 'qa/add.jade'
    post:(req,res,next)->
      result = 
        success:0
      req.body.html = safeConverter.makeHtml req.body.md
      req.body.user_id = res.locals.user.id
      req.body.user_headpic = res.locals.user.head_pic
      req.body.user_nick = res.locals.user.nick
      func_question.add req.body,(error,q)->
        if error 
          result.info = error.message
        else
          result.success = 1
          func_timeline.add 
            who_id:res.locals.user.id
            who_headpic:res.locals.user.head_pic
            who_nick:res.locals.user.nick
            target_url:"/qa/"+q.id
            target_name:q.title
            action:"发起了一个提问："
            desc:q.html.replace(/<p>(.*?)<\/p>/g,"$1\n").replace(/<[^>]*?>/g,"").substr(0,300).replace(/[^\n]\n+[^\n]/g,"<br/>")
        
        res.send result
  "/:id":
    "get":(req,res,next)->
      func_question.getById req.params.id,(error,question)->
        if error then next error
        else
          question.updateAttributes
            visit_count:question.visit_count*1+1
          res.locals.question = question
          res.render 'qa/qa.jade'
  "/answer/:id/zan":
    post:(req,res,next)->
      result = 
        success:0
      func_answer.getById req.params.id,(error,ans)->
        if error
          result.info = error.message
        else
          (__F 'coin').add 1,ans.user_id,res.locals.user.nick+" 顶了你的回答"
          ans.updateAttributes
            zan_count:ans.zan_count*1+1
          result.success = 1
          result.answer = ans
        res.send result
  "/:id/add":
    post:(req,res,next)->
      result = 
        success:0
      req.body.html = safeConverter.makeHtml req.body.md
      req.body.user_id = res.locals.user.id
      req.body.user_headpic = res.locals.user.head_pic
      req.body.user_nick = res.locals.user.nick
      req.body.question_id = req.params.id
      func_answer.add req.body,(error,q)->
        if error 
          result.info = error.message
        else
          result.success = 1
        res.send result
module.exports.filters = 
  "/":
    get:['qa/all-question']
  "/add":
    get:['checkLogin']
    post:['checkLogin']
  "/:id":
    get:['freshLogin','qa/get-answers']
  "/:id/add":
    post:['checkLoginJson']
  "/answer/:id/zan":
    post:['checkLoginJson']