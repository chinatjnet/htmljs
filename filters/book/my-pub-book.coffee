module.exports = (req,res,next)->
  if res.locals.user
    (__F 'book').getByPubUserId res.locals.user.id,(error,books)->
      res.locals.myPubBooks = books
      next()
  else
    next()