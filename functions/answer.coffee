Ans = __M 'answers'
Ans.sync()
AnsZanHistory = __M 'answer_zan_history'
AnsZanHistory.sync()
Question = __M 'questions'
Comment = __M 'answer_comment'
Comment.sync()
User = __M 'users'
Question.hasMany Ans,{foreignKey:"question_id"}
Ans.belongsTo Question,{foreignKey:"question_id"}
User.hasOne Comment,{foreignKey:"user_id"}
Comment.belongsTo User,{foreignKey:"user_id"}
func_answer = 
  addComment:(answer_id,user_id,content,callback)->
    Ans.find
      where:
        id:answer_id
    .success (ans)->
      if not ans then callback new Error '不存在的回答'
      else
        ans.updateAttributes
          comment_count:ans.comment_count*1+1
        Comment.create
          answer_id:answer_id
          user_id:user_id
          content:content
        .success (comment)->
          callback null,comment
        .error (e)->
          callback e
  getCommentsByAnswerId:(answer_id,callback)->
    Comment.findAll
      where:
        answer_id:answer_id
      order:"id"
      include:[User]
    .success (answers)->
      callback null,answers
    .error (e)->
      callback e
  getByQuestionId:(q_id,page,count,condition,callback)->
    query = 
      offset: (page - 1) * count
      limit: count
      order: "id+sort desc"
    if condition then query.where = condition
    Ans.findAll(query)
    .success (answers)->
      callback null,answers
    .error (e)->
      callback e
  countByQuestionId:(q_id,condition,callback)->
    query = {}
    if condition then query.where = condition
    Ans.count(query)
    .success (count)->
      callback null,count
    .error (e)->
      callback e
  add:(data,callback)->
    Question.find
      where:
        id:data.question_id
    .success (q)->
      if not q then callback new Error '不存在的问题'
      else
        Ans.create(data)
        .success (ans)->
          q.updateAttributes
            answer_count:q.answer_count*1+1
          
          callback null,ans
        .error (e)->
          callback e
    .error (e)->
      callback e
  getAllWithQuestion:(page,count,condition,order,callback)->
    query = 
      offset: (page - 1) * count
      limit: count
      order: order || "id desc"
      include:[Question]
    if condition then query.where = condition
    Ans.findAll(query)
    .success (answers)->
      callback null,answers
    .error (e)->
      callback e
  getByIdWithQuestion:(id,callback)->
    Ans.find
      where:
        id:id
      include:[Question]
    .success (ans)->
      if not ans then callback new Error '不存在的回答'
      else
        callback null,ans
    .error (e)->
      callback e
  addZan:(answerId,userId,callback)->
    AnsZanHistory.find
      where:
        answer_id:answerId
        user_id:userId
    .success (his)->
      if his
        callback new Error '已经给本回答点过赞了，如果你点上瘾了，那为毛放弃治疗！'
      else
        AnsZanHistory.create
          answer_id:answerId
          user_id:userId
        Ans.find
          where:
            id:answerId
        .success (card)->
          if card
            card.updateAttributes
              zan_count: if card.zan_count then (card.zan_count+1) else 1
          callback null,card
        .error (e)->
          callback e
__FC func_answer,Ans,['getAll','getById','delete','update','count']
module.exports = func_answer