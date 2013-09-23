Question = __M 'questions'

User = __M 'users'
Tag = __M 'tags'
QuestionTag = __M 'question_tag'
QuestionTag.sync()
User.hasOne Question,{foreignKey:"user_id"}
Question.belongsTo User,{foreignKey:"user_id"}
QuestionEditHistory = __M 'qa_edit_history'
User.hasOne QuestionEditHistory,{foreignKey:"user_id"}
QuestionEditHistory.belongsTo User,{foreignKey:"user_id"}
QuestionEditHistory.sync()
# Tag.hasMany Question,{joinTableName:"question_tag"}
# Question.hasMany Tag,{joinTableName:"question_tag"}
Question.sync()
User.sync()
Tag.sync()

func_question = 
  getAllEditHistory:(q_id,callback)->
    QuestionEditHistory.findAll
      where:
        question_id:q_id
      order:"id desc"
      include:[User]
    .success (his)->
      callback null,his
    .error (e)->
      callback e
  addEditHistory:(q_id,user_id,reason,callback)->
    QuestionEditHistory.create
      question_id:q_id
      user_id:user_id
      reason:reason
    .success (qeh)->
      callback null,qeh
    .error (e)->
      callback e
  getById:(id,callback)->
    Question.find
      where:
        id:id
      include:[User]
    .success (q)->
      if not q then callback new Error '不存在的问题'
      else
        callback null,q
    .error (e)->
      callback e
  addTagsToQuestion:(question_id,tagIds)->
    QuestionTag.findAll
      where:
        questionId:question_id
    .success (qts)->
      qts.forEach (qt)->
        qt.destroy()
      tagIds.forEach (tagid)->
        QuestionTag.create
          questionId:question_id
          tagId:tagid
  getAll: (page,count,condition,order,callback)->
    query = 
      offset: (page - 1) * count
      limit: count
      order: order || "id desc"
      include:[User]
    if condition then query.where = condition
    Question.findAll(query)
    .success (ms)->
      callback null,ms
    .error (e)->
      callback e
__FC func_question,Question,['delete','update','add','count']
module.exports = func_question