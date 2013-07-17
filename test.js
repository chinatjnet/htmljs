var read = require("readability")
var request = require ("request")

request.get("http://www.weakweb.com/articles/255.html",function(r,s,text){
  read.parse(text, "http://www.weakweb.com/articles/255.html", function(result) {
    console.log(result.title, result.content);
});
})
