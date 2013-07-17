require ("coffee-script");
require ("iced-coffee-script");

var server = require ("./index.coffee")

require('http').createServer(server).listen(server.get("port"),function(){
    console.log("Express server listening on port " + server.get("port"));
  });