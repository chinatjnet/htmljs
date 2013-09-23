module.exports = (req,res,next)->
  (__F 'comment').getAllByTargetId "act_"+req.params.id,1,10,null,(error,comments)->
    res.locals.comments = comments
    next()