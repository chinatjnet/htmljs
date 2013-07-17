func_article = require './../functions/article.coffee'
module.exports = (req,res,next)->
  func_article.getRecent (error,recents)->
    
    res.locals.recents = recents
    next()
  