func_article = __F 'article'
module.exports = (req,res,next)->
  page = req.query.page || 1
  count = req.query.count || 30
  func_article.count {user_id:res.locals.user.id,is_yuanchuang:1},(error,_count)->
    if error then next error
    else
      res.locals.total=_count
      res.locals.totalPage=Math.ceil(_count/count)
      res.locals.page = (req.query.page||1)
      func_article.getAll page,count,{user_id:res.locals.user.id,is_yuanchuang:1},(error,articles)->
        if error then next error
        else
          res.locals.articles = articles
          next()