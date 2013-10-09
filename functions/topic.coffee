Topic = __M 'topics'
TopicComment = __M 'topic_comments'
User = __M 'users'
User.hasOne Topic,{foreignKey:"user_id"}
Topic.belongsTo User,{foreignKey:"user_id"}
Topic.sync()
TopicComment.sync()
func_topic = 
  addComment:(data,callback)->
    
  getById:(id,callback)->
    Topic.find
      where:
        id:id
      include:[User]
    .success (topic)->
      if not topic then callback new Error '不存在的话题'
      else
        callback null,topic
    .error (e)->
      callback e
__FC func_topic,Topic,['add','getAll','delete','update',"count","addCount"]
module.exports = func_topic