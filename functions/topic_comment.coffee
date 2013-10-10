TopicComment = __M 'topic_comments'
TopicComment.sync()
Topic = __M 'topics'
func_comment = 
  add:(data,callback)->
    Topic.find
      where:
        id:data.topic_id
    .success (topic)->
      if not topic then callback new Error '不存在的话题'
      else
        data.uuid = (require 'node-uuid').v4()
        TopicComment.create(data)
        .success (comment)->
          callback null,comment,topic
        .error (e)->
          callback e
    .error (e)->
      callback e
  getLast:(topic_id,user_id,callback)->
    TopicComment.find
      where:
        topic_id:topic_id
        user_id:user_id
      order:"id desc"
    .success (comment)->
      if comment then callback null,comment
      else
        callback new Error 'no comment'
    .error (e)->
      callback e
__FC func_comment,TopicComment,['update','delete','count','getAll']
module.exports = func_comment