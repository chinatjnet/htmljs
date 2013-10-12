pagedown = require("pagedown")
safeConverter = pagedown.getSanitizingConverter()
func_topic = __F 'topic'
func_topic_comment = __F 'topic_comment'
func_info = __F 'info'
func_user = __F 'user'
moment = require 'moment'
module.exports.controllers = 
  "/":
    get:(req,res,next)->

      res.render 'topic/index.jade'

  "/add":
    get:(req,res,next)->

      res.render 'topic/add.jade'

    post:(req,res,next)->
      result = 
        success:0
      req.body.html = safeConverter.makeHtml req.body.md
      req.body.user_id = res.locals.user.id
      req.body.user_headpic = res.locals.user.head_pic
      req.body.user_nick = res.locals.user.nick
      req.body.last_comment_time = new Date()
      func_topic.add req.body,(error,topic)->
        if error 
          result.info = error.message
        else
          result.success = 1
          (__F 'index').add topic.uuid
          (__F 'coin').add 20,res.locals.user.id,"发布了一个话题"
        res.send result
  "/:id":
    get:(req,res,next)->
      func_topic.getById req.params.id,(error,topic)->
        if error then next error
        else
          res.locals.topic = topic
          func_topic.addCount topic.id,'visit_count'
          res.render 'topic/topic.jade'
  "/:id/add":
    post:(req,res,next)->
      result = 
        success:0
      req.body.html = safeConverter.makeHtml req.body.md
      req.body.user_id = res.locals.user.id
      req.body.user_headpic = res.locals.user.head_pic
      req.body.user_nick = res.locals.user.nick
      req.body.topic_id = req.params.id
      func_topic_comment.getLast req.params.id,res.locals.user.id,(error,c)->
        if c
          console.log moment(c.createdAt).valueOf()
          console.log new Date()
          if (new Date()).getTime()-moment(c.createdAt).valueOf() <60000
            result.info = '跟帖间隔不能小于60秒'
            res.send result
            return
        func_topic_comment.add req.body,(error,comment,topic)->
          if error 
            result.info = error.message
          else
            result.success = 1
            topic.updateAttributes
              last_comment_time:new Date()
              last_comment_user_id:res.locals.user.id
              last_comment_user_nick:res.locals.user.nick
              comment_count:topic.comment_count*1+1
            (__F 'coin').add 1,res.locals.user.id,"发布了一个话题的跟帖"
            func_info.add 
              target_user_id:topic.user_id
              type:5
              source_user_id:res.locals.user.id
              source_user_nick:res.locals.user.nick
              time:new Date()
              target_path:"/topic/"+topic.id
              action_name:"【回复】了您的话题"
              target_path_name:topic.title
              content:req.body.html
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
                    target_path:"/topic/"+topic.id
                    action_name:"在回帖中【提到】了你"
                    target_path_name:topic.title
                    content:req.body.html
          res.send result
module.exports.filters = 
  "/":
    get:['freshLogin','topic/all-topics']
  "/add":
    get:['checkLogin']
    post:['checkLoginJson']
  "/:id":
    get:['freshLogin','topic/all-comments']
  "/:id/add":
    post:['checkLoginJson']