func_column = __F 'column'
module.exports = (req,res,next)->
  func_column.getAll 1,10,{is_publish:1},(error,columns)->
    res.locals.columns = columns
    next()