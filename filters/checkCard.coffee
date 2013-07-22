func_card = require './../functions/card.coffee'
module.exports=(req,res,next)->
    if res.locals.user && res.locals.user.card_id
      func_card.getById res.locals.user.card_id,(error,card)->
        if card
          res.locals.card = card
        next()
    else
      next()
        