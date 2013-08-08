func_card = require './../functions/card.coffee'
module.exports = (req,res,next)->
  func_card.getHots (error,hots)->
    res.locals.hots = hots
    next()
  