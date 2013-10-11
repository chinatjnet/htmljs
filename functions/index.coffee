
Article = __M 'articles'
Question = __M 'questions'
Card = __M 'cards'
Index = __M 'indexinfos'
Index.sync()
module.exports = 
  count:(callback)->
    Index.count()
    .success (count)->
      callback null,count
    .error (e)->
      callback e
  getAll:(page,count,callback)->
    #select * from indexinfos  left join articles  on articles.uuid = indexinfos.info_id left join questions on questions.uuid = indexinfos.info_id;
    sequelize.query("select indexinfo.createdAt AS createdAt,indexinfo.sort AS sort,indexinfo.id AS id,
 article.id as article_id,
 article.user_id as article_user_id,
 article.user_nick as article_user_nick,
 article.user_headpic as article_user_headpic ,
 article.title as article_title,
 article.comment_count as article_comment_count,
 article.visit_count as article_visit_count,
 article.column_id as article_column_id,

 card.id as card_id,
 card.user_id as card_user_id,
 card.head_pic as card_head_pic,
 card.nick as card_nick,

 question.id as question_id,
 question.user_id as question_user_id,
 question.user_nick as question_user_nick,
 question.user_headpic as question_user_headpic ,
 question.title as question_title,
 question.answer_count as question_answer_count,
 question.visit_count as question_visit_count,

 topic.id as topic_id,
 topic.user_id as topic_user_id,
 topic.user_nick as topic_user_nick,
 topic.user_headpic as topic_user_headpic ,
 topic.title as topic_title,
 topic.comment_count as topic_comment_count,
 topic.visit_count as topic_visit_count

 from indexinfos indexinfo
 left join articles  article on article.uuid = indexinfo.info_id
 left join questions  question on question.uuid = indexinfo.info_id 
 left join cards  card on card.uuid = indexinfo.info_id 
 left join topics  topic on topic.uuid = indexinfo.info_id 
 order by indexinfo.sort desc,indexinfo.createdAt desc limit "+(page-1)*count+","+count+";",null, {raw: true})
    .success (data)->
      callback null,data
    .error (e)->
      callback e
  add:(id)->
    Index.create({info_id:id})
  update:(id,data,callback)->
    Index.find
      where:
        id:id
    .success (index)->
      if not index then callback new Error 'no found'
      else
        index.updateAttributes(data)
        .success ()->
          callback null,index
        .error (e)->
          callback e
    .error (e)->
      callback e