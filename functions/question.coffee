Question = __M 'questions'

User = __M 'users'
User.hasOne Question,{foreignKey:"user_id"}
Question.belongsTo User,{foreignKey:"user_id"}
Question.sync()
User.sync()
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
__FC func_question,Question,['delete','update','add','getAll','count']
module.exports = func_question