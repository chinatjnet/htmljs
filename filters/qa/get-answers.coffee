func_answer = __F 'answer'
module.exports = (req,res,next)->
  func_answer.getByQuestionId req.params.id,1,100,null,(error,answers)->
    if error then next error
    else
      res.locals.answers = answers
      next()