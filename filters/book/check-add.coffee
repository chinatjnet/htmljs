module.exports = (req,res,next)->
  if !req.body.title||!req.body.pic||!req.body.url||!req.body.price||!req.body.author
    next new Error '信息不完整'
  else
    next()