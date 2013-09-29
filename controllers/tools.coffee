func_tools = __F 'tool'
UglifyJS = require("uglify-js")
fs = require 'fs'
config = __C
module.exports.controllers = 

  "/":
    "get":(req,res,next)->
      # (__F 'user').getAll 1,1000,null,(error,users)->
      #   users.forEach (user)->
      #     if user.card_id
      #       (__F 'card').getById user.card_id,(e,card)->
      #         user.updateAttributes
      #           sex:card.sex
      #           weibo_name:user.nick
      #           nick:card.nick
      func_tools.getAll 1,50,null,"id",(error,tools)->
        if error then next error
        else
          res.locals.tools = tools
          res.render 'tools/index.jade'
  "/:name":
    get:(req,res,next)->
      func_tools.getAll 1,50,null,"id",(error,tools)->
        if error then next error
        else
          res.locals.tools = tools
          func_tools.addCountByName req.params.name,(error,tool)->
            res.locals.t = tool
            next()
  "/unicode":
    "get":(req,res,next)->
      res.render 'tools/unicode.jade'
  "/beautify":
    "get":(req,res,next)->
      res.render 'tools/beautify.jade'
    "post":(req,res,next)->
      result = 
        success:1
      try 
        console.log req.files
        if req.files&&req.files['jsfile']
          code = UglifyJS.minify(req.files['jsfile'].path);
          source = config.upload_path+(new Date().getTime())+Math.random()
          fs.writeFileSync source,code.code
          res.download source,req.files['jsfile'].name
        else if req.body.text
          result.data = UglifyJS.minify(req.body.text, {fromString: true})
          res.send result
      catch e
        result.success = 0
        result.info = e.message
        res.send result