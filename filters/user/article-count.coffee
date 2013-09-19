func_article = __F 'article'
module.exports = (req,res,next)->
  func_article.count {user_id:res.locals.user.id,is_yuanchuang:1},(error,_count)->
    res.locals.article_count =_count
    next()