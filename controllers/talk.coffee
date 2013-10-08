func_card = __F 'card'
module.exports.controllers = 
  "/:uuid":
    get:(req,res,next)->
      func_card.getByUUID req.params.uuid,(error,card)->
        res.locals.target_card = card
        res.render 'talk/talk.jade'