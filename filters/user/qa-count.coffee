func_question = __F 'question'
module.exports = (req,res,next)->
  func_question.count {user_id:res.locals.user.id},(error,_count)->
    res.locals.qa_count =_count
    next()