module.exports = (req,res,next)->
  condition = null
  page = req.query.page || 1
  count = req.query.count || 30
  (__F 'topic').count condition,(error,_count)->
    if error then next error
    else
      res.locals.total=_count
      res.locals.totalPage=Math.ceil(_count/count)
      res.locals.page = (req.query.page||1)
      (__F 'topic').getAll page,count,condition,"sort desc,last_comment_time desc",(error,topics)->
        if error then next error
        else
          res.locals.topics = topics
          next()