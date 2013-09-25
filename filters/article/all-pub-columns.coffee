module.exports = (req,res,next)->
  (__F 'column').getAll 1,100,["is_publish = 1 and user_id = ? or is_public = 1", res.locals.user.id],null,(error,columns)->
    res.locals.columns = columns
    next()