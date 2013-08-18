module.exports = (req,res,next)->
  if res.locals.user 
    (__F 'book').getByUserId res.locals.user.id,(error,books)->
      res.locals.mybooks = books
      next()
  else
    next()