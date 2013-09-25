module.exports = (req,res,next)->
  (__F 'column').getById req.params.id,(error,column)->
    res.locals.column = column
    next()