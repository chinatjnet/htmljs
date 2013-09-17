Sequelize = require 'sequelize'
module.exports = 
  id:"int"
  title:"varchar(200)"
  person_limit:"int"
  time:Sequelize.DATE
  location:"varchar(255)"
  map_url:"varchar(1000)"
  partner:"text"
  desc_md:"text"
  desc_html:"text"
  banner:"varchar(255)"
  comment_count:
    type:"int"
    defaultValue:0
  visit_count:
    type:"int"
    defaultValue:0
  is_publish:
    type:"tinyint"
    defaultValue:"0"