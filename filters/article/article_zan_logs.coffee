func_article = __F 'article'
module.exports = (req,res,next)->
  func_article.getZansByArticleId req.params.id,(error,zan_logs)->
    res.locals.zan_logs = zan_logs
    res.locals.zan_guo = false
    if zan_logs && res.locals.user
      zan_logs.forEach (log)->
        if log.user_id == res.locals.user.id
          res.locals.zan_guo = true
          res.locals.zan_score = log.score
    next()