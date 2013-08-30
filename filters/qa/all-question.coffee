module.exports = (req,res,next)->
  condition = null
  if req.query.filter
    condition=condition||{}
    req.query.filter.split(":").forEach (f)->
      kv = f.split '|'
      if kv.length
        condition[kv[0]]=kv[1]
        res.locals["filter_"+kv[0]]=kv[1]
  page = req.query.page || 1
  count = req.query.count || 20
  (__F 'question').count condition,(error,_count)->
    if error then next error
    else
      res.locals.total=_count
      res.locals.totalPage=Math.ceil(_count/count)
      res.locals.page = (req.query.page||1)
      (__F 'question').getAll page,count,condition,(error,questions)->
        if error then next error
        else
          res.locals.questions = questions
          next()