func_coin = __F 'coin'
module.exports = (req,res,next)->
  page = req.query.page || 1
  count = req.query.count || 30
  func_coin.count {user_id:res.locals.user.id},(error,_count)->
    if error then next error
    else
      res.locals.total=_count
      res.locals.totalPage=Math.ceil(_count/count)
      res.locals.page = (req.query.page||1)
      func_coin.getAll page,count,{user_id:res.locals.user.id},"createdAt desc",(error,coinhis)->
        if error then next error
        else
          res.locals.coinhis = coinhis
          next()