Card = __M 'cards'

Visit_log = __M 'card_visit_log'

User = __M 'users'
CardZanHistory = __M 'card_zan_history'
CardZanHistory.sync()
User.hasOne Card,{foreignKey:"user_id"}
Card.belongsTo User,{foreignKey:"user_id"}
Card.sync()
User.sync()
Visit_log.sync()
User.sync()
#Card.hasOne User,{foreignKey:"card_id"}
func_card =  
  getByUserId:(id,callback)->
    Card.find
      where:
        user_id:id
    .success (card)->
      callback null,card
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
          Visit_log.find
            where:
              card_id:cardId
              user_id:visitor.id
          .success (v)->
            if v
              v.updateAttributes
                user_headpic:visitor.head_pic
            else
              Visit_log.create
                card_id:cardId
                user_id:visitor.id
                user_nick:visitor.nick
                user_headpic:visitor.head_pic
  getVisitors:(cardId,callback)->
    Visit_log.findAll
      where:
        card_id:cardId
      limit:20
      order: "updatedAt desc"
    .success (logs)->
      callback null,logs
    .error (error)->
      callback error
  addZan:(cardId,userId,callback)->
    CardZanHistory.find
      where:
        card_id:cardId
        user_id:userId
    .success (his)->
      if his
        callback new Error '已经给这位【大叔/阿姨】点过赞了，如果你点上瘾了，那为毛放弃治疗！'
      else
        CardZanHistory.create
          card_id:cardId
          user_id:userId
        Card.find
          where:
            id:cardId
        .success (card)->
          if card
            card.updateAttributes
              zan_count: if card.zan_count then (card.zan_count+1) else 1
          callback null,card.zan_count
        .error (e)->
          callback e
  addComment:(cardId)->
    Card.find
      where:
        id:cardId
    .success (card)->
      if card
        card.updateAttributes
          comment_count: if card.comment_count then (card.comment_count+1) else 1
    .error (e)->
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
  getAll:(page,count,condition,callback)->
    query = 
      offset: (page - 1) * count
      limit: count
      order: "users.coin desc,cards.zan_count+cards.visit_count desc"
      include:[User]
    if condition then query.where = condition
    Card.findAll(query)
    .success (ms)->
      callback null,ms
    .error (e)->
      callback e
__FC func_card,Card,['update','count','delete','getById','add']
module.exports = func_card