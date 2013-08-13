Act = __M 'acts'
Act.sync()
ActJoiner = __M 'act_joiners'
ActJoiner.sync()
module.exports = 
  add:(data,callback)->
    Act.create(data)
    .success (act)->
      callback null,act
    .error (e)->
      callback e
  getById:(id,callback)->
    Act.find
      where:
        id:id
    .success (act)->
      if act 
        callback null,act
      else
        callback new Error '不存在的活动'
    .error (e)->
      callback e
  getAll:(page,count,condition,callback)->
    query = 
      offset: (page - 1) * count
      limit: count
      order: "id desc"
    if condition then query.where = condition
    Act.findAll(query)
    .success (acts)->
      callback null,acts
    .error (error)->
      callback error
  addJoiner:(act_id,user,callback)->
    ActJoiner.find
      where:
        act_id:act_id
        user_id:user.id
    .success (aj)->
      if aj then callback new Error '已经报名过'
      else
        ActJoiner.create
          act_id:act_id
          user_id:user.id
          user_headpic:user.head_pic
          user_nick:user.nick
        .success (aj)->
          callback null,aj
        .error (e)->
          callback e
    .error (e)->
      callback e
  getAllJoiners:(act_id,callback)->
    ActJoiner.findAll
      where:
        act_id:act_id
    .success (ajs)->
      callback null,ajs
    .error (e)->
      callback e
