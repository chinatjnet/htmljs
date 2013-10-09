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

__FC func_comment,TopicComment,['update','delete','count','getAll']
module.exports = func_comment