func_act = __F 'act'
module.exports.controllers = 
  "/":
    get:(req,res,next)->
      page = req.params.page || 1
      count = 20
      func_act.getAll page,count,null,(error,acts)->
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
      res.render 'act/act.jade'
module.exports.filters = 
  "/add":
    get:['checkAdmin']
    post:['checkAdmin']