F_user = __F 'user'
F_article = __F 'article'
module.exports.controllers = 
  "/":
    get:(req,res,next)->
      res.render 'admin/articles.jade'
  "/article/:id/update":
    get:(req,res,next)->
      F_article.update req.params.id,req.query,(error)->
        if error then next error
        else
          res.redirect 'back'
module.exports.filters = 
  "/":
    get:['checkLogin','checkAdmin','article/all-publish-articles']
  "/article/update":
    get:['checkLogin','checkAdmin']