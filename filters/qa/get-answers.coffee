func_answer = __F 'answer'
module.exports = (req,res,next)->
  condition = 
    question_id:req.params.id
  page = req.query.page || 1
  count = req.query.count || 30
  (__F 'answer').count condition,(error,_count)->
    if error then next error
    else
      res.locals.total=_count
      res.locals.totalPage=Math.ceil(_count/count)
      res.locals.page = (req.query.page||1)
      (__F 'answer').getAll page,count,condition,(error,answers)->
        if error then next error
        else
          res.locals.answers = answers
          next()