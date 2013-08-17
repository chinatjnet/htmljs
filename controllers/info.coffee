func_info = __F 'info'
module.exports.controllers = 
  "/read":
    get:(req,res,next)->

    post:(req,res,next)->
      func_info.getByUserId res.locals.user.id,(error,infos)->
        infos.forEach (info)->
          info.updateAttributes({is_read:1}) 
module.exports.filters = 
  "/read":
    get:[]
    post:['checkLogin',"checkCard"]