module.exports = (req,res,next)->
  (__F 'answer').getAllWithQuestion 1,10,null,"id desc",(error,answers)->
    res.locals.recent_answers = answers
    next()