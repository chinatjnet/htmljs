Book = __M 'books'
Book.sync()
User = __M 'users'

func_book = 
  sellToUser:(bookId,user,callback)->
    Book.find
      where:
        id:bookId
    .success (book)->
      if not book
        callback new Error '不存在的书籍'
      else  
        book.updateAttributes
          user_id:user.id
          user_nick:user.nick
          is_selled:1
        .success ()->
          callback null,book
        .error (e)->
          callback e
    .error (e)->
      callback e
  getByUserId:(userId,callback)->
    Book.findAll
      where:
        user_id:userId
    .success (books)->
      callback null,books
    .error (e)->
      callback e
  getByPubUserId:(userId,callback)->
    Book.findAll
      where:
        pub_user_id:userId
    .success (books)->
      callback null,books
    .error (e)->
      callback e
__FC func_book,Book,['add','getAll','delete','update','count','getById']

module.exports = func_book