module.exports = (req,res,next)->
  condition = 
    is_yuanchuang:0
  page = req.query.page || 1
  count = req.query.count || 30
  (__F 'read').count condition,(error,_count)->
    if error then next error
    else
      res.locals.total=_count
      res.locals.totalPage=Math.ceil(_count/count)
      res.locals.page = (req.query.page||1)
      (__F 'read').getAll page,count,condition,(error,articles)->
        if error then next error
        else
          res.locals.all_reads = articles
          next()