CoinHistory = __M 'coin_history'
User = __M 'users'
CoinHistory.sync()
func_coin = 
  add:(count,user_id,reason,callback)->
    CoinHistory.findAll
      where:
        user_id:user_id
        day:(new Date()).getTime()/1000*60*60*24
    .success (his)->
      if his 
        total = 0
        his.forEach (h)->
          total+=h.step
        if total>__C.day_coin_max
          callback new Error '已经达到本日最高积分（'+__C.day_coin_max+'）'
        else
          User.find
            where:
              id:user_id
          .success (u)->
            if u
              u.updateAttributes
                coin:u.coin*1+count

          CoinHistory.create
            user_id:user_id
            step:count
            day:(new Date()).getTime()/1000*60*60*24
            reason:reason
          .success (his)->
            callback&&callback null,his
          .error (e)->
            callback&&callback e
    .error (e)->
      callback&&callback e
module.exports = func_coin