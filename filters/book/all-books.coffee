module.exports = (req,res,next)->
  condition = null
  page = req.query.page || 1
  count = req.query.count || 30
  (__F 'book').count condition,(error,_count)->
    if error then next error
    else
      res.locals.total=_count
      res.locals.totalPage=Math.ceil(_count/count)
      res.locals.page = (req.query.page||1)
      (__F 'book').getAll page,count,condition,(error,books)->
        if error then next error
        else
          res.locals.books = books
          next()