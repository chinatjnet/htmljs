
module.exports.controllers = 
  "/":
    get:(req,res,next)->

      res.render 'act/act.jade'
    post:(req,res,next)->

module.exports.filters = 
  "/":
    get:[]
    post:[]