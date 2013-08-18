


var exec = require('child_process').exec,
    last = exec('sendmail -t <<EOF'+
'From: 前端乱炖 <admin@html-js.com>'+     
'To: xinyu198736@gmail.com   '+                                      
'Cc: 676588498@qq.com   '+                             
'Subject: 今日你收到的活动邀请汇总   '+                                                
'———————————-            '+                              
'代码诗人芋头，你好'+    
'以下是你今天收到且还未处理过的活动邀请：'+   

'DDDesign邀请你参加“用你的脚步去发现美吧 ”活动'+    
'活动开始时间：2013-04-17 08:00:00'+    
'活动地点在各地'+
'查看详情：'+ 
'———————————'+    
'EOF');

last.stdout.on('data', function (data) {
    console.log('标准输出：' + data);
});

last.on('exit', function (code) {
    console.log('子进程已关闭，代码：' + code);
});
