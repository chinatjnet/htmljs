Tool = __M 'tools'
Tool.sync()
func_tool = 
  getByName:(name,callback)->
    Tool.find
      where:
        name:name
    .success (tool)->
      if not tool then callback new Error '不存在的工具'
      else
        callback null,tool
    .error (e)->
      callback e
  addCountByName:(name,callback)->
    Tool.find
      where:
        name:name
    .success (tool)->
      if not tool then callback new Error '不存在的工具'
      else
        tool.updateAttributes 
          visit_count:tool.visit_count*1+1
        .success ()->
          callback null,tool
    .error (e)->
      callback e  
__FC func_tool,Tool,['add','update','getAll','addCount']
module.exports = func_tool