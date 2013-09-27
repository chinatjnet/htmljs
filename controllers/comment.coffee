func_comment = __F 'comment'
func_info = __F 'info'
func_article = __F 'article'
func_card = __F 'card'
func_user = __F 'user'
func_question = __F 'question'
pagedown = require("pagedown")
safeConverter = pagedown.getSanitizingConverter()
moment = require 'moment'
module.exports.controllers = 
  "/:target_id":
    get:(req,res,next)->
      result = 
        success:0
      func_comment.getAll 1,20,{target_id:req.params.target_id},(error,comments)->
        if error
          result.info = error.message
        else
          result.success = 1
          comments.forEach (comment)->
            comment.createdAt = moment(comment.createdAt).fromNow()
          result.comments = comments
        res.send result
  "/add":
    get:(req,res,next)->

    post:(req,res,next)->
      result = 
        success:0
      req.body.html = safeConverter.makeHtml req.body.md
      req.body.user_id = res.locals.user.id
      req.body.user_headpic = res.locals.user.head_pic
      req.body.user_nick = res.locals.user.nick

      func_comment.add req.body,(error,comment)->
        if error 
          result.info = error.message
        else
          result.success = 1
          comment.createdAt = moment(comment.createdAt).format("LLL")
          result.comment = comment
          (__F 'coin').add 1,res.locals.user.id,"添加了评论"
          match = null
          if match = req.body.target_id.match(/^article_([0-9]*)$/)
            func_article.addComment(match[1])
            func_article.getById match[1],(error,article)->

              if article
                func_info.add 
                  target_user_id:article.user_id
                  type:2
                  source_user_id:res.locals.user.id
                  source_user_nick:res.locals.user.nick
                  time:new Date()
                  target_path:'/article/'+article.id
                  action_name:"【评论】了您的原创文章"
                  target_path_name:article.title
                  content:req.body.html
          else if match = req.body.target_id.match(/^card_([0-9]*)$/)
            func_card.addComment(match[1])
            func_card.getById match[1],(error,card)->
              if card
                func_info.add 
                  target_user_id:card.user_id
                  type:2
                  source_user_id:res.locals.user.id
                  source_user_nick:res.locals.user.nick
                  time:new Date()
                  target_path:"/card/"+card.id
                  action_name:"【评论】了您的名片"
                  target_path_name:card.nick+"的名片"
                  content:req.body.html
          else if match = req.body.target_id.match(/^question_([0-9]*)$/)
            func_question.addComment(match[1])
            func_question.getById match[1],(error,question)->
              if question
                func_info.add 
                  target_user_id:question.user_id
                  type:2
                  source_user_id:res.locals.user.id
                  source_user_nick:res.locals.user.nick
                  time:new Date()
                  target_path:"/qa/"+question.id
                  action_name:"【评论】了您的问题"
                  target_path_name:question.title
                  content:req.body.html
          else if match = req.body.target_id.match(/^act_([0-9]*)$/)
            (__F 'act').addCount(match[1],"comment_count")

          if atname = req.body.md.match(/\@([^\s]*)/)
            atname = atname[1]
            func_user.getByNick atname,(error,user)->
              if user
                func_info.add 
                  target_user_id:user.id
                  type:6
                  source_user_id:res.locals.user.id
                  source_user_nick:res.locals.user.nick
                  time:new Date()
                  target_path:"/"+req.body.target_id.replace("_","/")
                  action_name:"在评论中【提到】了你"
                  target_path_name:"查看出处"
                  content:req.body.html
        res.send result

module.exports.filters = 
  "/add":
    post:['checkLoginJson']