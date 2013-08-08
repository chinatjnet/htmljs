Bao = __M 'baos'
Bao.sync()
Comments = __M 'bao_comments'
Comments.sync()

module.exports =  
  getAll:(page,count,condition,callback)->
    query = 
      offset: (page - 1) * count
      limit: count
      order: "id desc"
    if condition then query.where = condition
    Comments.findAll(query)
    .success (baos)->
      callback null,baos
    .error (error)->
      callback error
  add:(data,callback)->
    Comments.create(data)
    .success (bao)->
      callback null,bao
    .error (error)->
      callback error