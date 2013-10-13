func_article = __F 'article'
module.exports = (req,res,next)->
  func_article.getAll 1,10,{column_id:res.locals.article.column_id},(error,column_articles)->
    res.locals.column_articles= column_articles
    next()