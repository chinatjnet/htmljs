Info = __M 'infos'
Info.sync()
func_info = 
  getByUserId:(user_id,callback)->
    Info.findAll
      where:
        is_read:0
        target_user_id:user_id
    .success (infos)->
      callback null,infos
    .error (e)->
      callback e
  add:(data,callback)->
    Info.create(data)
      .success (info)->
        callback&&callback null,info
      .error (e)->
        callback&&callback e
  read:(user_id,callback)->
    sequelize.query 'update infos set is_read = 1 where target_user_id = ?', null, {raw: true},[user_id]
__FC func_info,Info,['getAll','getById','delete','update','count']
module.exports = func_info