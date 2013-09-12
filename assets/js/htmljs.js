var HtmlJS =HtmlJS||{};
HtmlJS.util = function(){
  return {
    ajax:function(url,data,type,success,error,btn){
      if(btn){
       btn.prop("disabled",true);
        btn.attr("data-text",btn.html()).html("提交中...")
      }
      $.ajax({
        url:url,
        data:data,
        dataType:"json",
        type:type,
        success:function(data){
          if(btn){
            btn.prop("disabled",false);
            btn.html(btn.attr("data-text"))
          }
          if(data.isnotlogin){
              alert("请先登录")
                window.location.href='/user/login?redirect='+encodeURIComponent(window.location.href)
            }else if(data.success){
            success(data)
            }else{
              alert(data.info)
            }
        },
        error:function(e){
          if(btn){
            btn.prop("disabled",false);
            btn.html(btn.attr("data-text"))
          }
          error(e);
        }
      })
    }
  }
}();