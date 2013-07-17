func_card = require './../functions/card.coffee'
module.exports = (req,res,next)->
  func_card.getRecents (error,recents)->
    res.locals.recents = recents
    next()
  