func_article = __F 'article'
module.exports = (req,res,next)->
  func_article.getById req.params.id,(error,article)->
    if error then next error
    else if not article then next new Error '不存在的文章'
    else
      res.locals.article = article
      next()