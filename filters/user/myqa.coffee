func_question = __F 'question'
module.exports = (req,res,next)->
  page = req.query.page || 1
  count = req.query.count || 30
  func_question.count {user_id:res.locals.user.id},(error,_count)->
    if error then next error
    else
      res.locals.total=_count
      res.locals.totalPage=Math.ceil(_count/count)
      res.locals.page = (req.query.page||1)
      func_question.getAll page,count,{user_id:res.locals.user.id},"sort desc,id desc",(error,questions)->
        if error then next error
        else
          res.locals.questions = questions
          next()