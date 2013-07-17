module.exports =  
  id:"int"
  user_id:"int"
  user_nick:"varchar(100)"
  user_headpic:"varchar(255)"
  title:"varchar(255)"
  md:"text"
  html:"text"
  visit_count:
    defaultValue:0
    type:"int"
  comment_count:
    defaultValue:0
    type:"int"
  publish_time:"int"
  is_publish:
    defaultValue:0
    type:"tinyint"
  sort:"int"
  is_top:"tinyint"
  type:
    type:"int" #1原创，2精品推荐，3实例学习，4其他
    defaultValue:1
  quote_url:"varchar(255)" #引用原文url
  desc:"text"
  