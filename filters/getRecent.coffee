func_article = require './../functions/article.coffee'
module.exports = (req,res,next)->
  func_article.getRecent (error,recents)->
    if recents
      recents = recents.splice(0,10)
    res.locals.recents = recents
    next()
  