var HtmlJS =HtmlJS||{};
HtmlJS.util = function(){
  return {
    ajax:function(url,data,type,success,error){
      $.ajax({
        url:url,
        data:data,
        dataType:"json",
        type:type,
        success:function(data){
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
          error(e);
        }
      })
    }
  }
}();