require './../lib/modelLoader.coffee'
require './../lib/functionLoader.coffee'
func_timeline = __F 'timeline'
moment = require 'moment'
func_article = __F 'article'
func_column = __F 'column'
func_card = __F 'card'
func_question = __F 'question'

# (__M 'articles').findAll()
# .success (qs)->
#   qs.forEach (q)->
#     if not q.uuid
#       q.updateAttributes
#         uuid:uuid.v4()

qs = []
(__M 'cards').findAll()
.success (_qs)->
  qs = qs.concat(_qs)
  (__M 'articles').findAll({where:{is_yuanchuang:1}})
    .success (_qs)->
      qs = qs.concat(_qs)
      (__M 'questions').findAll()
      .success (_qs)->
        qs = qs.concat(_qs)

        qs.sort (q1,q2)->
          if isNaN(q1.createdAt.getTime())
            return true
          else if isNaN(q2.createdAt.getTime())
            return false
          else
           return q1.createdAt.getTime() < q2.createdAt.getTime()
        console.log qs
        qs.forEach (q)->
          if not isNaN(q.createdAt.getTime())
            (__M 'indexinfos').create({info_id:q.uuid,createdAt:q.createdAt})