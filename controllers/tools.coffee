module.exports.controllers = 
  "/":
    "get":(req,res,next)->
      # (__F 'user').getAll 1,1000,null,(error,users)->
      #   users.forEach (user)->
      #     if user.card_id
      #       (__F 'card').getById user.card_id,(e,card)->
      #         user.updateAttributes
      #           sex:card.sex
      #           weibo_name:user.nick
      #           nick:card.nick
