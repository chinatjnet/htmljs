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
  users: require("./../models/users.coffee")
  cards: require("./../models/cards.coffee")
  visit_log: require './../models/card_visit_log'
  
User = sequelize.define("users", models.users)
User.sync()
Card = sequelize.define("cards", models.cards)
Card.sync()
VisitLog = sequelize.define 'card_visit_log',models.visit_log
VisitLog.sync()


module.exports =  
  getByWeiboId:(id,callback)->
    User.find
      where:
        weibo_id:id
    .success (user)->
      callback null,user
    .error (error)->
      callback error
  add:(data,callback)->
    User.create(data)
    .success (user)->
      callback null,user
    .error (error)->
      callback error
  getById:(id,callback)->
    User.find
      where:
        id:id
    .success (user)->
      callback null,user
    .error (error)->
      callback error
  connectCard:(uid,cardId,callback)->
    User.find
      where:
        id:uid
    .success (user)->
      if user
        Card.find
          where:
            id:cardId
        .success (card)->
          if card&&!card.user_id
            card.updateAttributes
              user_id:uid
            .success ()->
              user.updateAttributes
                card_id:cardId
              .success ()->
                callback null,user
                
              .error (error)->
                callback error
            .error (error)->
              callback error
          else
            callback new Error '名片已经被关联'
      else
        callback new Error '不存在的用户'
    .error (error)->
      callback error
  visitCard:(userId,cardId,callback)->
    User.find
      where:
        id:userId
    .success (u)->
      if not u
        callback new Error '不存在的用户'
      else
        VisitLog.create 
          user_id:userId
          card_id:cardId
          user_nick:u.nick
          user_headpic:u.head_pic
        .success (log)->
          callback null,log
        .error (error)->
          callback error
    .error (error)->
      callback error