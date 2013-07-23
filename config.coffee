config =
  run_port:5678
  mysql_table:"htmljs"
  mysql_username:"root" #数据库用户名
  mysql_password:"" #数据库密码
  upload_path:__dirname+"/uploads/"
  base_path:__dirname
  script_ext:".coffee"
  sdks:
    sina:
      app_key:""
      app_secret:""
      redirect_uri : 'http://www.html-js.com/user/sina_cb'
module.exports = config
