func_tools = __F 'tool'
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
      func_tools.getAll 1,50,null,(error,tools)->
        if error then next error
        else
          res.locals.tools = tools
          res.render 'tools/index.jade'
  "/:name":
    get:(req,res,next)->
      func_tools.addCountByName req.params.name,(error,tool)->
        next()
  "/unicode":
    "get":(req,res,next)->
      res.render 'tools/unicode.jade'