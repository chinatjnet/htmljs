config = require("./../config.coffee")
path = require 'path'
Sequelize = require("sequelize")
sequelize = new Sequelize(config.mysql_table, config.mysql_username, config.mysql_password,
  define:
    underscored: false
    freezeTableName: true
    charset: 'utf8'
    collate: 'utf8_general_ci'
)
module.exports = global.__M= (modelName)->
    return sequelize.define modelName, require path.join config.base_path,"models",modelName+config.script_ext