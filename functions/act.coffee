Act = __M 'acts'
Act.sync()
module.exports = 
  add:(data,callback)->
    Act.create(data)
    .success (act)->
      callback null,act
    .error (e)->
      callback e

  getAll:(page,count,condition,callback)->
    query = 
      offset: (page - 1) * count
      limit: count
      order: "id desc"
    if condition then query.where = condition
    Act.findAll(query)
    .success (acts)->
      callback null,acts
    .error (error)->
      callback error