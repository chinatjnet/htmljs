config = require("./../config.coffee")
Sequelize = require("sequelize")
sequelize = new Sequelize(config.mysql_table, config.mysql_username, config.mysql_password,
  define:
    underscored: false
    freezeTableName: true
    charset: 'utf8'
    collate: 'utf8_general_ci'
)
models =
  baos: require("./../models/baos.coffee")
  bao_comments: require("./../models/bao_comments.coffee")
Bao = sequelize.define("baos", models.baos)
Bao.sync()
Comments = sequelize.define("bao_comments", models.bao_comments)
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