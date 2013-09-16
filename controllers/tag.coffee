func_tag = __F 'tag'
func_timeline = __F 'timeline'
pagedown = require("pagedown")
safeConverter = pagedown.getSanitizingConverter()
module.exports.controllers = 
  '/':
    get:(req,res,next)->

      res.render 'tag/index.jade'
  "/add":
    get:(req,res,next)->

      res.render 'tag/add.jade'
    post:(req,res,next)->
      req.body.desc = safeConverter.makeHtml req.body.desc_md
      func_tag.add req.body,(error,tag)->
        if error then next error
        else
          func_timeline.add 
            who_id:res.locals.user.id
            who_headpic:res.locals.user.head_pic
            who_nick:res.locals.user.nick
            target_url:"/tag/"+tag.id
            target_name:tag.name
            action:"添加了一个新标签："
            desc:tag.desc
          res.redirect '/tag'
  "/:id":
    get:(req,res,next)->
      func_tag.getById req.params.id,(error,tag)->
        if error then next error
        else if not tag then next new Error '不存在的标签'
        else
          func_tag.getQuestionsById tag.id,1,20,(error,qt)->
            res.locals.qts =  qt
            res.locals.tag = tag
            res.render 'tag/tag.jade'
  "/n/:name":
    get:(req,res,next)->
      func_tag.getByName req.params.name,(error,tag)->
        if error then next error
        else if not tag then next new Error '不存在的标签'
        else
          func_tag.getQuestionsById tag.id,1,20,(error,qt)->
            res.locals.qts =  qt
            res.locals.tag = tag
            res.render 'tag/tag.jade'
  "/:id/edit":
    get:(req,res,next)-> 
      func_tag.getById req.params.id,(error,tag)->
        if error then next error
        else
          res.locals.tag =tag
          res.render 'tag/add.jade'
    post:(req,res,next)->
      req.body.desc = safeConverter.makeHtml req.body.desc_md
      func_tag.update req.body.id,req.body,(error,tag)->
        if error then next error
        else
          res.redirect '/tag'    

module.exports.filters = 
  "/":
    get:['freshLogin','tag/all-tags']
  "/:id":
    get:['freshLogin']
  "/add":
    get:["checkLogin"]
    post:["checkLogin"]