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
          (__F 'coin').add 5,res.locals.user.id,"发布了一条问题"
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
        else if not question then next new Error '不存在的问题'
        else
          func_question.update question.id,{visit_count:question.visit_count*1+1}
          res.locals.question = question
          res.render 'qa/qa.jade'
  "/:id/edit":
    "get":(req,res,next)->
      func_question.getById req.params.id,(error,question)->
        if error then next error
        else if not question then next new Error '不存在的问题'
        else if question.user_id != res.locals.user.id then next new Error '没有权限，这不是您发布的问题'
        else
          res.locals.question = question
          res.render 'qa/edit-question.jade'
    "post":(req,res,next)->
      req.body.html = safeConverter.makeHtml req.body.md
      func_question.update req.params.id,req.body,(error)->
        if error 
          next error
        else
          res.redirect '/qa/'+req.params.id
  "/answer/:id/edit":
    get:(req,res,next)->
      func_answer.getByIdWithQuestion req.params.id,(error,ans)->
        if error then next error
        else if not ans then next new Error '不存在的回答'
        else if ans.user_id != res.locals.user.id then next new Error '没有权限，这不是您发布的回答'
        else
          res.locals.answer = ans
          res.render 'qa/edit-answer.jade'
    "post":(req,res,next)->
      req.body.html = safeConverter.makeHtml req.body.md
      func_answer.update req.params.id,req.body,(error)->
        if error 
          next error
        else
          res.redirect '/qa/'+req.body.question_id+"#answer-"+req.params.id
  "/answer/:id/comment":
    get:(req,res,next)->
      result = 
        success:0
      func_answer.getCommentsByAnswerId req.params.id,(error,answers)->
        if error 
          result.info = error.message
        else
          result.answers = answers
          result.success = 1
        res.send result
    "post":(req,res,next)->
      result = 
        success:0
      func_answer.addComment req.params.id,res.locals.user.id,req.body.content,(error,comment)->
        if error 
          result.info = error.message
        else
          result.comment = comment
          result.success = 1
        res.send result
  "/answer/:id/zan":
    post:(req,res,next)->
      result = 
        success:0
      func_answer.addZan req.params.id,res.locals.user.id,(error,ans)->
        if error
          result.info = error.message
        else
          (__F 'coin').add 1,ans.user_id,res.locals.user.nick+" 顶了你的回答"
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
    get:['freshLogin','qa/all-question','qa/hot-question','qa/recent-answers']
  "/add":
    get:['checkLogin']
    post:['checkLogin']
  "/:id":
    get:['freshLogin','qa/get-answers']
  "/:id/edit":
    get:['checkLogin']
    post:['checkLogin']
  "/answer/:id/edit":
    get:['checkLogin']
    post:['checkLogin']
  "/:id/add":
    post:['checkLoginJson']
  "/answer/:id/zan":
    post:['checkLoginJson']