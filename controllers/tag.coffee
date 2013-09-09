func_tag = __F 'tag'
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
          res.redirect '/tag'
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
  "/add":
    get:["checkLogin"]
    post:["checkLogin"]