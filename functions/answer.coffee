Ans = __M 'answers'
Ans.sync()
Question = __M 'questions'

Question.hasMany Ans,{foreignKey:"question_id"}
Ans.belongsTo Question,{foreignKey:"question_id"}

func_answer = 
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
  getAll:(page,count,condition,callback)->
    query = 
      offset: (page - 1) * count
      limit: count
      order: "zan_count desc,id desc"
    if condition then query.where = condition
    Ans.findAll(query)
    .success (ans)->
      callback null,ans
    .error (error)->
      callback error
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
__FC func_answer,Ans,['getById','delete','update','count']
module.exports = func_answer