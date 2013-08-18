module.exports = (req,res,next)->
  if !res.locals.user
    next new Error '请先登录再操作，<a href="/user/login">点此登录</a>'
  else if !res.locals.card
    next new Error '您还没有加入花名册，不能操作，<a href="/cards">点此领取或者创建花名册</a>'
  else if !(res.locals.card.address&&res.locals.card.tel)
    next new Error '必须填写收货地址和手机号才能领取，<a href="/edit-card">点此修改信息</a>'
  else
    (__F 'book').getByUserId res.locals.user.id,(error,books)->
      if books.length >= 3
        next new Error '对不起，每个人最多只能领取3本书，<a href="/book">返回</a>'
      else
        next()