Act = __M 'acts'
Act.sync()
ActJoiner = __M 'act_joiners'
ActJoiner.sync()
User =__M 'users'
User.hasMany ActJoiner,{foreignKey:"user_id"}
ActJoiner.belongsTo User,{foreignKey:"user_id"}
Act.hasMany ActJoiner,{foreignKey:"act_id"}
ActJoiner.belongsTo Act,{foreignKey:"act_id"}
func_act = 
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
      include:[User]
    .success (ajs)->
      callback null,ajs
    .error (e)->
      callback e
  getAll:(page,count,condition,order,include,callback)->
    if arguments.length == 4
      callback = order
      order = null
      include = null
    else if arguments.length == 5
      callback = include
      include = null
    query = 
      offset: (page - 1) * count
      limit: count
      order: order || "id desc"
      include:[ActJoiner]
    if condition then query.where = condition
    if include then query.include = include
    Act.findAll(query)
    .success (ms)->

      callback null,ms
    .error (e)->
      callback e
__FC func_act,Act,['delete','update','add','getById','count','addCount']
module.exports = func_act
