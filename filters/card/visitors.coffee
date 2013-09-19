module.exports = (req,res,next)->
  if res.locals.card
    (__F "card").getVisitors res.locals.card.id,(error,visitors)->
      if error then next error
      else
        res.locals.visitors = visitors
      next()
  else
    next()