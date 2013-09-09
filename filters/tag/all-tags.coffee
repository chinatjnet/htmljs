module.exports = (req,res,next)->
  (__F 'tag').getAll 1,200,null,"qa_count desc,id desc",(error,tags)->
    res.locals.tags = tags
    next()