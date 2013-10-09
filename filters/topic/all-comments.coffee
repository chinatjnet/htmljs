func_topic_comment = __F 'topic_comment'

module.exports = (req,res,next)->
  condition = 
    topic_id:req.params.id
  page = req.query.page || 1
  count = req.query.count || 30
  func_topic_comment.count condition,(error,_count)->
    if error then next error
    else
      res.locals.total=_count
      res.locals.totalPage=Math.ceil(_count/count)
      res.locals.page = (req.query.page||1)
      func_topic_comment.getAll page,count,condition,"id",(error,comments)->
        if error then next error
        else
          res.locals.comments = comments
          next()