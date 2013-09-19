func_info = __F 'info'
module.exports = (req,res,next)->
  page = req.query.page || 1
  count = req.query.count || 30
  func_info.count {target_user_id:res.locals.user.id},(error,_count)->
    if error then next error
    else
      res.locals.total=_count
      res.locals.totalPage=Math.ceil(_count/count)
      res.locals.page = (req.query.page||1)
      func_info.getAll page,count,{target_user_id:res.locals.user.id},"id desc",(error,infos)->
        if error then next error
        else
          res.locals.infos = infos
          func_info.read res.locals.user.id
          next()