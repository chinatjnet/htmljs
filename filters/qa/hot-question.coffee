module.exports = (req,res,next)->
  (__F 'question').getAll 1,10,null,'visit_count+answer_count desc',(error,questions)->
    res.locals.hot_questions = questions
    next() 