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
  cards: require("./../models/cards.coffee")
  visit_logs: require("./../models/card_visit_log.coffee")
Card = sequelize.define("cards", models.cards)
Card.sync()
Visit_log = sequelize.define("visit_logs", models.visit_logs)
Visit_log.sync()


module.exports =  
  getAll:(page,count,condition,callback)->
    query = 
      offset: (page - 1) * count
      limit: count
      order: "id desc"
    if condition then query.where = condition
    Card.findAll(query)
    .success (cards)->
      callback null,cards
    .error (error)->
      callback error
  getByUserId:(id,callback)->
    Card.find
      where:
        user_id:id
    .success (card)->
      callback null,card
    .error (error)->
      callback error
  getById:(id,callback)->
    Card.find
      where:
        id:id
    .success (card)->
      callback null,card
    .error (error)->
      callback error
  add:(data,callback)->
    Card.create(data)
    .success (card)->
      callback null,card
    .error (error)->
      callback error
  count:(condition,callback)->
    query = {}
    if condition then query.where = condition
    Card.count(query)
    .success (count)->
      callback null,count
    .error (error)->
      callback error
  update:(id,data,callback)->
    Card.find
      where:
        id:id
    .success (card)->
      card.updateAttributes(data)
      .success ()->
        callback null,card
      .error (error)->
        callback error
    .error (error)->
      callback error
  addVisit:(cardId,visitor)->
    Card.find
      where:
        id:cardId
    .success (card)->
      if card
        card.updateAttributes
          visit_count: if card.visit_count then (card.visit_count+1) else 1
        if visitor
          Visit_log.create
            card_id:cardId
            user_id:visitor.id
            user_nick:visitor.nick
            user_headpic:visitor.head_pic
  getVisitors:(cardId,callback)->
    Visit_log.findAll
      where:
        card_id:cardId
      limit:8
    .success (logs)->
      callback null,logs
    .error (error)->
      callback error
  getHots:(callback)->
    Card.findAll
      offset: 0
      limit: 10
      order: "visit_count desc"
    .success (cards)->
      callback null,cards
    .error (error)->
      callback error
  getRecents:(callback)->
    Card.findAll
      offset: 0
      limit: 10
      order: "id desc"
    .success (cards)->
      callback null,cards
    .error (error)->
      callback error