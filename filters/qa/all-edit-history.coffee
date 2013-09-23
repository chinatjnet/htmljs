func_question = __F 'question'
module.exports = (req,res,next)->
  func_question.getAllEditHistory req.params.id,(error,ehis)->
    res.locals.ehis = ehis
    next()