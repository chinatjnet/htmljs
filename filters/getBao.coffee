func_bao = require './../functions/bao.coffee'
module.exports = (req,res,next)->
  func_bao.getAll 1,20,{card_id:req.params.id},(error,baos)->
    res.locals.baos = baos
    next()
  