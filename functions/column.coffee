Column = __M 'columns'
User = __M "users"
User.hasOne Column,{foreignKey:"user_id"}
Column.belongsTo User,{foreignKey:"user_id"}
Column.sync()

func_column = 
  getAll:(page,count,condition,desc,callback)->
    query = 
      offset: (page - 1) * count
      limit: count
      order: if desc then desc else "article_count desc"
      include:[User]
    if condition then query.where = condition
    Column.findAll(query)
    .success (columns)->
      callback null,columns
    .error (error)->
      callback error
  getById:(id,callback)->
    Column.find
      where:
        id:id
      include:[User]
    .success (column)->
      callback null,column
    .error (e)->
      callback e
__FC func_column,Column,['delete','add','addCount']
module.exports = func_column