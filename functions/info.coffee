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
    if data.type == 1
      Info.find
        where:
          is_read:0
          target_user_id:data.target_user_id
          source_user_id:data.source_user_id
          target_path:data.target_path
      .success (info)->
        if info
          info.updateAttributes(data)
          .success ()->
            callback null,info
          .error (e)->
            callback e
        else
          Info.create(data)
          .success (info)->
            callback null,info
          .error (e)->
            callback e
      .error (e)->
        callback e


__FC func_info,Info,['getAll','getById','delete','update']
module.exports = func_info