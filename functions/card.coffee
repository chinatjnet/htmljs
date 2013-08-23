Card = __M 'cards'
Card.sync()
Visit_log = __M 'card_visit_log'
Visit_log.sync()


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
  addZan:(cardId,callback)->
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
      order: "zan_count+visit_count desc"
    if condition then query.where = condition
    Card.findAll(query)
    .success (ms)->
      callback null,ms
    .error (e)->
      callback e
__FC func_card,Card,['update','count','delete','getById','add']
module.exports = func_card