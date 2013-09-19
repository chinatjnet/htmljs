func_user = __F 'user'
func_info = __F 'info'
md5 = require 'MD5'
module.exports=(req,res,next)->
    if req.cookies._p
      p = req.cookies._p.split ':'
      if p.length==2
        uid = p[0]
        token = p[1]
        func_user.getById uid,(error,user)->
          if user 
            if md5(user.weibo_token)==token
              
              res.locals.user = user
              func_info.count {target_user_id:user.id,is_read:0},(error,count)->
                res.locals.unread_count = count
                next();
            else
              res.redirect '/user/login?redirect='+encodeURIComponent(req.url)
          else
            res.redirect '/user/login?redirect='+encodeURIComponent(req.url)
      else
        res.redirect '/user/login?redirect='+encodeURIComponent(req.url)
    else
      res.redirect '/user/login?redirect='+encodeURIComponent(req.url)