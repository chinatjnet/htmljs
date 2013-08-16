module.exports = (req,res,next)->
  
  page = req.query.page || 1
  count = req.query.count || 30
  (__F 'act').count null,(error,_count)->
    if error then next error
    else
      res.locals.total=_count
      res.locals.totalPage=Math.ceil(_count/count)
      res.locals.page = (req.query.page||1)
      (__F 'act').getAll page,count,null,(error,acts)->
        if error then next error
        else
          res.locals.acts = acts
          next()