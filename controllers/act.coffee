func_act = __F 'act'
module.exports.controllers = 
  "/":
    get:(req,res,next)->
      page = req.params.page || 1
      count = 20
      func_act.getAll page,count,{is_publish:1},(error,acts)->
        res.locals.acts = acts
        res.render 'act/index.jade'

  "/add":
    get:(req,res,next)->
      res.render 'act/add.jade'
    post:(req,res,next)->
      func_act.add req.body,(error,act)->
        if error then next error
        else
          res.redirect '/act'
  "/:id":
    get:(req,res,next)->
      func_act.getById req.params.id,(error,act)->
        if error then next error
        else
          res.locals.act = act
          func_act.getAllJoiners req.params.id,(error,joiners)->
            res.locals.joiners = joiners ||[]
            res.render 'act/act.jade'
  "/:id/join":
    post:(req,res,next)->
      result = 
        success:0
      func_act.addJoiner req.params.id,res.locals.user,(error,joiner)->
        if error 
          result.info = error.message
          res.send result
        else
          result.success = 1
          result.data = joiner
          res.send result
module.exports.filters = 
  "/add":
    get:['checkLogin','checkAdmin']
    post:['checkLogin','checkAdmin']
  "/:id/join":
    post:['checkLogin','checkCard']