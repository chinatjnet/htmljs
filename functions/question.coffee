Question = __M 'questions'

User = __M 'users'
Tag = __M 'tags'
QuestionTag = __M 'question_tag'
QuestionTag.sync()
User.hasOne Question,{foreignKey:"user_id"}
Question.belongsTo User,{foreignKey:"user_id"}

# Tag.hasMany Question,{joinTableName:"question_tag"}
# Question.hasMany Tag,{joinTableName:"question_tag"}
Question.sync()
User.sync()
Tag.sync()

func_question = 
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