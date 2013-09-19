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

Ans.hasMany AnsZanHistory,{foreignKey:"answer_id"}
AnsZanHistory.belongsTo Ans,{foreignKey:"answer_id"}

User.hasOne Ans,{foreignKey:"user_id"}
Ans.belongsTo User,{foreignKey:"user_id"}

func_info = __F 'info'
func_user  = __F 'user'
func_answer = 
  addComment:(answer_id,user_id,user_nick,content,callback)->
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
          func_info.add 
            target_user_id:ans.user_id
            type:2
            source_user_id:user_id
            source_user_nick:user_nick
            time:new Date()
            target_path:"/qa/"+ans.question_id+"#answer-"+ans.id
            action_name:"【评论】了你的回答"
            target_path_name:ans.md.replace(/\s/g," ").substr(0,100)
            content:content
          if atname = content.match(/\@([^\s]*)/)
            atname = atname[1]
            func_user.getByNick atname,(error,user)->
              if user
                func_info.add 
                  target_user_id:user.id
                  type:6
                  source_user_id:user_id
                  source_user_nick:user_nick
                  time:new Date()
                  target_path:"/qa/"+ans.question_id+"#answer-"+ans.id
                  action_name:"在评论中【提到】了你"
                  target_path_name:"查看出处"
                  content:content
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
      where:
        question_id:q_id
      offset: (page - 1) * count
      limit: count
      order: "zan_count desc,id desc"
      include:[AnsZanHistory,User]
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
          
          callback null,q,ans
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
  getZan:(answerId,callback)->
    AnsZanHistory.findAll
      where:
        answer_id:answerId
      include:[User]
    .success (his)->
      callback null,his
    .error (e)->
      callback e
  addZan:(answerId,user,callback)->
    AnsZanHistory.find
      where:
        answer_id:answerId
        user_id:user.id
    .success (his)->
      if his
        callback new Error '已经给本回答点过赞了，如果你点上瘾了，那为毛放弃治疗！'
      else
        AnsZanHistory.create
          answer_id:answerId
          user_id:user.id
          user_nick:user.nick
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