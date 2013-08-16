F_user = __F 'user'
F_read = __F 'read'
module.exports.controllers = 
  "/:id/update":
    get:(req,res,next)->
      F_read.update req.params.id,req.query,(error)->
        if error then next error
        else
          res.redirect 'back'
  "/:id/del":
    get:(req,res,next)->
      F_read.delete req.params.id,(error)->
        if error then next error
        else
          res.redirect 'back'
module.exports.filters = 
  "/*":
    get:['checkLogin','checkAdmin']