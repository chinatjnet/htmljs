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
  is_yuanchuang:
    defaultValue:0
    type:"tinyint"
  sort:"int"
  is_top:"tinyint"
  type:
    type:"int" 
    defaultValue:1
  quote_url:"varchar(255)" #引用原文url
  desc:"text"
  main_pic:"varchar(255)"
  tagNames:"varchar(255)"
  