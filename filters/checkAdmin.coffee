module.exports = (req,res,next)->
  if res.locals.user.is_admin 
    next()
  else
    res.render 'no-permission.jade'
