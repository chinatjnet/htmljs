Column = __M 'columns'
User = __M "users"
User.hasOne Column,{foreignKey:"user_id"}
Column.belongsTo User,{foreignKey:"user_id"}
Column.sync()

func_column = 
  getAll:(page,count,condition,callback)->
    query = 
      offset: (page - 1) * count
      limit: count
      order: "article_count desc"
      include:[User]
    if condition then query.where = condition
    Column.findAll(query)
    .success (columns)->
      callback null,columns
    .error (error)->
      callback error

__FC func_column,Column,['delete','add']
module.exports = func_column