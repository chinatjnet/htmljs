
Article = __M 'articles'
Article.sync()
Visit_log = __M 'article_visit_logs'
Visit_log.sync()

cache = 
  recent:[]
func_article =  
  getAll:(page,count,condition,callback)->
    query = 
      offset: (page - 1) * count
      limit: count
      order: "sort desc,id desc"
    if condition then query.where = condition
    Article.findAll(query)
    .success (articles)->
      cache.recent = articles
      callback null,articles
    .error (error)->
      callback error
  getByUserIdAndType:(id,type,callback)->
    Article.findAll
      where:
        user_id:id
        type:type
        is_publish:1
      order: "id desc"
      limit:20
    .success (articles)->
      callback null,articles
    .error (error)->
      callback error
  getByUrl:(url,callback)->
    Article.find
      where:
        quote_url:url
    .success (article)->
      callback null,article
    .error (error)->
      callback error
  add:(data,callback)->
    Article.create(data)
    .success (article)->
      article.updateAttributes
        sort:article.id
      callback null,article
    .error (error)->
      callback error
  addComment:(articleId)->
    Article.find
      where:
        id:articleId
    .success (article)->
      if article
        article.updateAttributes
          comment_count: if article.comment_count then (article.comment_count+1) else 1
  addVisit:(articleId,visitor)->
    Article.find
      where:
        id:articleId
    .success (article)->
      if article
        article.updateAttributes
          visit_count: if article.visit_count then (article.visit_count+1) else 1
        if visitor
          Visit_log.create
            article_id:articleId
            user_id:visitor.id
            user_nick:visitor.nick
            user_headpic:visitor.head_pic
  getVisitors:(articleId,callback)->
    Visit_log.findAll
      where:
        article_id:articleId
      limit:10
    .success (logs)->
      callback null,logs
    .error (error)->
      callback error
  getRecent:(callback)->
    callback null,cache.recent
__FC func_article,Article,['update','count','delete','getById']
module.exports=func_article
