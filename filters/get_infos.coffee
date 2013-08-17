func_info = __F 'info'
module.exports = (req,res,next)->
  if res.locals.user
    func_info.getByUserId res.locals.user.id,(error,infos)->
      res.locals.infos = infos
      next() 
  else
    next()
  