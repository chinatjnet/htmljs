func_comment = __F 'comment'
pagedown = require("pagedown")
safeConverter = pagedown.getSanitizingConverter()
module.exports.controllers = 
  "/add":
    get:(req,res,next)->

    post:(req,res,next)->
      result = 
        success:0
      req.body.html = safeConverter.makeHtml req.body.md
      func_comment.add req.body,(error,comment)->
        if error 
          result.info = error.message
        else
          result.success = 1
          result.comment = comment
        res.send comment

module.exports.filters = 
  "/":
    get:[]
    post:[]