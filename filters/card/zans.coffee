func_card = __F 'card'

module.exports = (req,res,next)->
  func_card.getZans req.params.id,(error,zans)->
    res.locals.zans = zans
    next()