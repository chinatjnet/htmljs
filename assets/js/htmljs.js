var HtmlJS =HtmlJS||{};
HtmlJS.util = function(){
  return {
    loginback:null,
    logincallback:function(){
      $("#login_iframe").css({display:"none"});
      $("#login_layer").css({display:"none"});
      HtmlJS.util.loginback&&HtmlJS.util.loginback();
    },
    ajax:function(url,data,type,success,error,btn,loginback){
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
              alert("此操作需要登录，登录后会继续提交")
                ///window.location.href='/user/login?redirect='+encodeURIComponent(window.location.href)
                HtmlJS.util.loginback = loginback
                if($("#login_iframe").length){
                  $("#login_iframe").css({
                    left:$(window).width()/2-300,
                    display:"block"
                  })
                  $("#login_layer").css({
                    width:$("body").width(),
                    height:$("body").height(),
                    display:"block"
                  })
                }else{
                  var loginIframe = document.createElement("iframe");
                  $(loginIframe).css({
                    left:$(window).width()/2-300
                  })
                  loginIframe.src="/user/login?mini=1"
                  loginIframe.className = "login_iframe"
                  loginIframe.id = "login_iframe"
                  var loginLayer = document.createElement("div");
                  $(loginLayer).css({
                    width:$("body").width(),
                    height:$("body").height()
                  })
                  loginLayer.className = "login_layer"
                  loginLayer.id = "login_layer"
                  loginLayer.onclick=function(){
                    loginIframe.style.display="none"
                    loginLayer.style.display="none"
                  }
                  document.body.appendChild(loginLayer)
                  document.body.appendChild(loginIframe)
                }
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