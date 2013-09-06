var host = 'http://127.0.0.1:8080/soucheweb/pages/';
var DEBUG = false;
/* 系统消息 */
var sysMessage = function(){
	var message_url = host+"userMessageAction/getMessage.json";
	var pageSize = 30;
	var page = 1;
	/* 请xiaoxi */
	function requestSystermMessage(){	
		var url = message_url+"?page="+page+"&pageSize="+pageSize;
		Util.showLoadingView(false,null);
		$.getJSON(url, function() {
		})
		.done(function(data) {
			console.log(url);
			Util.isLogin(data.errorMessage);
			packagToMessageArray(data);
		})
		.always(function() { 
			Util.showLoadingView(false,null);
		});
	}
		
	//将json数据封装放入 messageArray
	function packagToMessageArray(data){
		var messageArray = new Array();
		if(!data.items) return;
		for(var i=0;i<data.items.length;i++){
			var msgData = data.items[i];
			var message = new Object;
			
			message.time = msgData.time;
			message.date = msgData.date;
			message.message = msgData.message;
			message.title = msgData.modelName
			message.carFramNumber = msgData.carJiaNumber;
			message.type = msgData.type;
			message.typeText = msgData.typeName;
			message.picUrl = msgData.pic;
			switch(message.type){
			case "xiajia":message.typeText ="已下架";break;
			case "yishou":message.typeText ="已售";break;
			case "passed":message.typeText ="审核通过";break;
			case "zaishou":message.typeText ="在售";break;
			case "not_passed":message.typeText ="审核未通过";break;
			case "yuyue":message.typeText ="已预约";break;
			case "qiugou":message.typeText ="求购";break;
			default:message.typeText ="";
			}
			messageArray[i] = message;
		}
		showMessageInListView(messageArray);
	}
	
	/* 
	 * 显示系统消息列表
	*/
	function showMessageInListView(messageArray){			
		/* 追加消息 */
		$("#messageList").append(Mustache.render(message_tpl,{messages:messageArray}));
	 	/* 是否需要显示加载更多cell */
	 	if(messageArray.length >= pageSize){
	 		if($("#loadMoreCell").length > 0){
				$("#loadMoreCell").appendTo($("#messageList"));
		 	}else{
			 	$("#messageList").append("<li data-icon='false' id='loadMoreCell'><span>加载更多</span></li>");
			 	/*加载更多点击事件*/
				$("#loadMoreCell").click(function(){
					page++;
					requestSystermMessage();			
				});
		 	}
	 	}
	 //	$("#messageList").listview("refresh");
 	}
	 	
	var message_tpl = null
	return {
	    data:{
	    },
	    init:function(_config){
	    	message_tpl = $("#message_tpl").html();
	      this._bind();
	    },
	    _bind:function(){
		    requestSystermMessage();
	    },
	    // 提交后清空页面数据和结构
	    clearAll:function(){
	      this.data = {}
	    }
  }
}();

/* 我的二手车 */
var mySecondHandCar = function(){
	//  车辆状态接口
	var car_status_url = host+"/dicAction/loadRootLevel.json?request_message=%7B%22type%22:%22yushou_audit_status%22%7D";
	// 车辆列表接口
	var car_list_url = host+"yushouAppAction/getYushouCar.json";
	// 删除车辆
	var car_delete_url = host+"yushouAppAction/delYushouCar.json"
	
	var currentFilterType = "all";//当前过滤条件
	var pageSize = 10;//每页显示的车辆数量
	var page = 1;

	/* 获取车量状态类型 */
	function requestCarStatusType(){	
		Util.showLoadingView(true,"loading");
		$.getJSON(car_status_url, function() {
		  console.log( "car_status_url success" );
		})
		.done(function(data) {
			Util.isLogin(data.errorMessage);
			showCarStatusMenu(data);
		})
		.fail(function() { 
			console.log("car_status request error");
			Util.showLoadingView(false,null);
		})
		.always(function() { 
			
		});
	}
	
	/*显示车辆状态菜单*/
	function showCarStatusMenu(data){
		var statusItemsHtml = "";
		for(var i=0;i<data.items.length;i++){
			var carStatus = data.items[i];
			statusItemsHtml += "<a data-rel='back'  data-role='button' data-value='"+carStatus.enName+"' class='filter_item'>"+carStatus.name+"</a>";
		}
		$("#filter_view").append(statusItemsHtml).trigger("create");
		//状态改变事件
		$(".filter_item").click(function(){
			//显示当前选择的筛选条件
			$("#filter_button_title").text($(this).text());
			//请求数据
			var filterType = $(this).data("value");
			requestMySecondHandCar(filterType);
		});
	}
	
	/*
	 * 请求2手车
	*/
	function requestMySecondHandCar(filterType){
		Util.showLoadingView(true,"loading");
		var status = "&status="+filterType;
		if(filterType == "all"){
			status = "";
		}
		var url = car_list_url+"?page="+page+"&pageSize="+pageSize+status;
		if(currentFilterType == filterType){
			page++;
		}else{
			page = 1;
		}
		
		$.getJSON(url, function() {
		  console.log( "success:"+url );
		})
		.done(function(data) {
			Util.isLogin(data.errorMessage);
			packageCarInfo(filterType, data);
		})
		.fail(function() { 
			console.log("getYushouCar request error");
		})
		.always(function() { 
			Util.showLoadingView(false,null);
		});
	}
	
	/* 封装车辆信息 */
	function packageCarInfo(filterType, data){
		var status = data.status;
		if(status == false){
			return;
		}
		var totalNum = data.totalNumber;
		var carArray = new Array();
		for(var i=0;i<totalNum;i++){
			var car = new Object;
			var carData = data.items[i]
			if(typeof carData == 'undefined'){
				break;
			}
			car.carId = carData.carId;
			car.title =  carData.modelName;
			car.carFramNumber = carData.carJiaNumber;
			car.iamgeUrl = carData.pic1;
			car.status = carData.status;
		    car.statusText = carData.statusName;//状态码
			car.wantBuyCount = carData.seeCarContactNum;//预售求购
			car.orderCount = carData.buyingNum;//在售预约
			car.zaishouYuyue = carData.buyingNum;
			car.publishTime = carData.dateCreate;
			car.canModify = carData.canModify;
			carArray[i] = car;
		}
		showCarInListView(filterType, carArray);
	}
	
	/* 
	 * 显示我的二手车到html页面 
	*/
	function showCarInListView(filterType, carArray){
			var listItems = "";
			
			listItems = Mustache.render (car_tpl,{
		        cars:carArray
		    })
			/* 删除之前已经存在的loadMoreCell */
			$("#loadMoreCell").remove();
			//同一过滤类型的车辆
			if(filterType == currentFilterType){
				$("#car_list_ul").append(listItems);
			}else{//不同过滤类型的车辆
		 		$("#car_list_ul").html(listItems);
		 	}
			//编辑按钮
			$(".car-edit").click(function(){
				var status = $(this).attr("data-canModify");
				var modifyCarId = $(this).attr("data-carid");
				console.log(status);
				// 跳转到修改页面
				if(status == "true"){
					popDetailB.data = {
						canModify : status,
						carId : 	modifyCarId
					};				
					console.log("need modify carid:"+modifyCarId);
					var confirmDelete = window.confirm("您确定要重新编辑吗?");
					if(confirmDelete == true){
			            $.mobile.changePage('popularize-detail-b.html');						
					}
				}
			});
		 	//当前消息类型
		 	currentFilterType = filterType;
		 	
		 	/* 控制load more cell的显示 */
		 	if($("#loadMoreCell").length > 0){
			 	$("#loadMoreCell").appendTo("#car_list_ul");
		 	}else{
			 	var loadMore_tpl = $("#loard_more_tpl").html();
			 	var loadMoreCell = Mustache.render(loadMore_tpl, {loadMore:"加载更多"})
			 	$("#car_list_ul").append(loadMoreCell);
 			 	/*加载更多的点击事件*/
				$("#loadMoreCell").click(function(){
					requestMySecondHandCar(currentFilterType);			
				});
		 	}
		 	if(carArray.length < pageSize){
			 	$("#loadMoreCell").remove();
		 	}
		 //	$("#car_list_ul li").listview().listview("refresh");
		 	
			//车辆删除按钮事件
			$(".car-del").click(function(){
				var carid =  $(this).data("carid");
				var confirmDelete = window.confirm("确定删除?\n"+$(this).text());
				if(confirmDelete == true){
					removeCar(carid);
				}
			});
		}
		
		/* 删除车辆 */
		function removeCar(carid){
			Util.showLoadingView(true,"");
			car_delete_url = car_delete_url+"?carId="+carid;
			//to do 提交服务器
			//to do.....
			console.log(car_delete_url);
			$.getJSON(car_delete_url, function() {
			})
			.done(function(data) {
				console.log(data);
				Util.isLogin(data.errorMessage);
				//更新界面
				$("li[data-carid='"+carid+"']").remove();
			})
			.fail(function() { 
				console.log("getYushouCar request error");
			})
			.always(function() { 
				Util.showLoadingView(false,null);
			});
		}
		
	var car_tpl = ""
	return {
	    data:{
	    },
	    init:function(_config){
        car_tpl = $("#car_tpl").html();
	      this._bind();
	    },
	    _bind:function(){
    		/* 获取车量状态类型 */
			requestCarStatusType();
			//页面加载后默认显示所有二手车
			requestMySecondHandCar("all");
			$("#mySecondHandCar .sc-recycle").click(function(){
				$("#car_list_div").addClass("is-del")
				$(this).addClass("hidden")
				$("#mySecondHandCar .sc-recycle-complete").removeClass("hidden")
			})
			$("#mySecondHandCar .sc-recycle-complete").click(function(){
				$("#car_list_div").removeClass("is-del")
				$(this).addClass("hidden")
				$("#mySecondHandCar .sc-recycle").removeClass("hidden")
			})
	    },
	    // 提交后清空页面数据和结构
	    clearAll:function(){
	      this.data = {}
	    }
    }
}();

/* 选择款式 */
var xuanZeKuanShi = function(){
	var brandName = '';
	var seriescode = "series-000";
	var myBrandId = null;
	var selectCanModify;
/* 	var series_api = host+"dicAction/loadRootLevelForCar.json?request_message={\"code\":\""+myBrandId+"\",\"type\":\"car-subdivision\"}"; */

	 /* 品牌和车系 */
	function requestSeriesWithBrandId(_brandId){
		myBrandId = (_brandId == null || _brandId=='') ? "brand-44" : _brandId;
		var series_api = host+"dicAction/loadRootLevelForCar.json?request_message={\"code\":\""+myBrandId+"\",\"type\":\"car-subdivision\"}";
		console.log(series_api+"|||");
		$.getJSON( series_api, function() {
		  console.log( "series_api success");
		})
		.done(function(data) { 
			Util.isLogin(data.errorMessage);
			showBrand(data);
		})
		.fail(function() { console.log( "error" ); })
		.always(function() { console.log( "complete" ); });
	}

	/*根据seriesCode 请求该车系的所有车型 */
	function requestCarModel(_seriesCode, $model_ul){
		if($model_ul.find("li").length > 0){
			return;
		}
		
		Util.showLoadingView(true,null);
		seriescode = _seriesCode;
		var parameters = "{\"code\":\""+seriescode+"\",\"type\":\"car-subdivision\"}"
		var model_api = host+"dicAction/loadNextLevel.json?request_message="+parameters;
		console.log(model_api);
		$.getJSON( model_api, function() {})
		.done(function(data) { 
			Util.isLogin(data.errorMessage);
			showCarModel(data, $model_ul, seriescode);
		})
		.fail(function() { console.log( "error" ); })
		.always(function() { Util.showLoadingView(false,null);});
	}
	
	/* 显示车型 */
	function showCarModel(data, $model_ul, seriescode){
		var modelArray = new Array();

		for(key in data.items){
			var model = new Object;
			var modelData = data.items[key];
			model.name = modelData.name;
			model.code = modelData.code;
			modelArray.push(model);
		}
		$model_ul = $model_ul.find("ul");
		$model_ul.append(Mustache.render(models_tpl,{model:modelArray})).trigger("create");

		// 车型点击事件
		$(".model_title").click(function(){
			// 车型id
			var carModelId = $(this).attr("id");
			//车型名称
			var carModelName = $(this).text();
			// 车系id
			var carSeriesId = seriescode;
			// 车系名称
			var carSeriesName = $("#"+seriescode).attr('data-name');
			// 车品牌id 
			var carBrandId = brandId;
			// 车品牌名称
			var carBrandName = "";
			//需要传递数据
			console.log("品牌id:"+brandId+"---车系："+seriescode+"-----车型id:"+$(this).attr("id"));
			var vinNum = popDetailB.data.vin;
			popDetailB.data = {
				vin:vinNum,
				carModelId : carModelId,
				carModelName : carModelName,
				carSeriesId : carSeriesId,
				carSeriesName : carSeriesName,
				carBrandId : carBrandId,
				carBrandName : xuanZeKuanShi.data.brandName,
				canModify:selectCanModify
			};
            $.mobile.changePage('popularize-detail-b.html');
            popDetailB.init();
            return false;			
		});
	}
		
	/*show brand*/
	function showBrand(data){
		/* 显示车系 */
		for(key in data.codes){
			var seriesData = data.codes[key];
			
			/* 显示品牌 */
			var brand = new Object;
			var brandArray = new Array();
			brand.name = key;//品牌
			console.log(brand.name);
			brandArray.push(brand);
			$("#series_and_model").append(Mustache.render(brands_tpl,{brands:brandArray})).trigger("create");
			
			/* 显示车系 */
			for(s in seriesData){
				var series = new Object;
				var seriesArray	= new Array();
				series.name = seriesData[s].name;
				series.code = seriesData[s].code;
				seriesArray.push(series);
				$(".series_list:last").append(Mustache.render(serieses_tpl,{series:seriesArray}));
				$(".series_list:last").trigger("create");
				
				/* 点击车系标题事件 */
			    var series_title = "#"+series.code;
			    $(series_title).click(function(){
					var $model_ul = $(this).next();
/* 					var $model_ul = $(".model[data-myid='"+series.code+"']"); */

					var series_code = $(this).attr("id");
					requestCarModel(series_code, $model_ul);
			    });
			}		
		}
		
	}

	var brands_tpl = null, serieses_tpl = null, models_tpl = null;
	return {
	    data:{
	    },
	    init:function(_config){
		    brands_tpl = $("#brands_tpl").html();
		    serieses_tpl = $("#serieses_tpl").html();
		    models_tpl = $("#models_tpl").html();   
	      this._bind();
	    },
	    _bind:function(){
			//brandCode:brandCode,brandName:brandName,brandUrl:brandUrl		
			selectCanModify = this.data.canModify; 
			branName = this.data.brandName;
			brandId = this.data.brandCode;
	    	//显示品牌图片
	    	$("#car_brand_img").attr("src", this.data.brandUrl);
			requestSeriesWithBrandId(this.data.brandCode);
	    },
	    // 提交后清空页面数据和结构
	    clearAll:function(){
	      this.data = {}
	    }
    }
}();


//检查是否是电话号码
function isPhoneNum (mobile) {
    if(mobile.length==0)
    {
       // alert('请输入手机号码！');           
       return false;
    }    
    if(mobile.length!=11)
    {
        // alert('请输入有效的手机号码！');        
        return false;
    }
    
    var myreg = /(^0{0,1}1[3|4|5|6|7|8|9][0-9]{9}$)/;
    if(!myreg.test(mobile))
    {
        // alert('请输入有效的手机号码！');            
        return false;
    }
    // alert('有效的手机号码！');
    return true;
};
/*
*register.html
*/
var register = function(){
    //检查注册表单
    function checkRegisterForm () {
        var errorMsg;
        var phoneNum = $('#phone').val();
        if (!isPhoneNum(phoneNum)) {
            $('#phone').focus();        
            errorMsg = '电话号码不正确';
            return errorMsg;
        };

        var ver = $('#verification').val();
        if (ver.length < 1) {
            $('#verification').focus();
            errorMsg = 'verification error';
            return errorMsg;
        };

        var pwd = $('#pwd').val();
        var repwd = $('#repwd').val();
        if (pwd.length != repwd.length || pwd.length < 6 || repwd.length < 6 || pwd != repwd) {
            $('#pwd').focus();
            errorMsg = 'pwd error';
            return errorMsg;
        };

        var person_name = $('#person_name').val();
        if (person_name.length < 1) {
            $('#person_name').focus();
            errorMsg = 'person_name error';
            return errorMsg;
        };

        var individual = $('#individual').val();
        if (individual == 1){
            var company = $('#company').val();
            if (company.length < 1) {
                $('#company').focus();
                errorMsg = 'company error';
                return errorMsg;
            };
        };
        
        errorMsg = '';
        return errorMsg;
    }    

    var config = {
    regApi:''
    }


    var Time = 60; //设置时间　单位：秒 
    var t=null; 	
	function starttime(o){

		if(t==null) {
			o.attr('disabled',true);
			t = setInterval(function(){e(o)},1000);
		}
	}
	function e(o){
		Time -= 1;	    	  	    
	    if (Time==0) {
	    	clearInterval(t);
	    	o.attr('disabled',false);
	    	o.val('获取验证码');	    	
	    	Time = 60;
	    	t = null;
	    }else {
	    	o.val(Time+'秒后可重新发送...'); 		    
	    }   
	    o.button( "refresh" );
  	}	

    return {
        data: {

        },

        init:function(_config){
            Util.mixin(config,_config);//将传入的配置混合到本地
            this._bind();      
        },

        _bind:function(){
            //绑定获得验证码
            $('#getver').bind('click', function () {
                var phoneNum = $('#phone').val();                    
                var isMobile = isPhoneNum(phoneNum);
                if (!isMobile) {
                    $('#phone').focus();
                    alert('phone error');
                    // navigator.notification.alert(
                    //     'phone error',  // message
                    //     null,         // callback
                    //     'error title',            // title
                    //     'Done'                  // buttonName
                    // );
                } else {
					starttime($(this));     
					var url = host + 'sendMessageAction/sendMessage.json';
                    var formdata = 'phoneNumber=' + phoneNum + '&type='+'register';
                    $.ajax({
                        type: 'POST',
                        url: url,
                        data: formdata,    
                        dataType:'json',                    
                        success: function (data) {
                        	
                        	if(data.msg){
                        		alert('data::' + data.msg);	
	                        		if(t != null){							
									clearInterval(t);
									Time = 60;
									t = null;
								}
								$('#getver').val("获取验证码");
								$('#getver').attr("disabled",false);
								$('#getver').button( "refresh" );
                        	} 
                        	else {
                        		alert('验证码已经发送');
                        	}

							
							
                        },
                        error: function (error) {

                        }
                    });
                };
                return false;
            });

            //绑定提交表单
            $('#submit').bind('click', function () {

                var errorMsg = checkRegisterForm();
                if (errorMsg.length > 0) {
                    alert(errorMsg);
                    // navigator.notification.alert(
                    //     errorMsg,  // message
                    //     null,         // callback
                    //     'error title',            // title
                    //     'Done'                  // buttonName
                    // );
                } else {
                    var url = host + 'registerUserAction/register.json';
                    var formdata = $('#register_form').serialize();                        
                    $.ajax({
                        type: 'POST',
                        url: url,                        
                        data: formdata,    
                        dataType:'json',                    
                        success:function (data) {
                        	if (data.id) {
                        		alert('注册出错' + data.id + ' ' + data.msg == undefined ? '' : data.msg);
                        	} else {
                        		$.mobile.changePage('loginorreg.html');
                        	}                        	
                        },
                        error:function (error) {
                        	alert('error::'+ error);
                        }
                    });
                };                    
                return false;
            }); 

            //绑定个人/公司select
            $('#individual').bind('change',function() {
                var select_val = $('#individual').val();
                if (select_val == 0) {
                    $('#company_container').hide();
                } else {
                    $('#company_container').show();
                }
            });
        },

        clearAll:function(){
            this.data = {};
          // $("***").val("")
        }
    }
}();

/*
*login.html
*/

var login = function() {
    //检查登陆表单
    function checkLoginForm() {
        var errorMsg;
        var phoneNum = $('#login_phone').val();
        if (!isPhoneNum(phoneNum)) {     
            $('#login_phone').focus();   
            errorMsg = '电话号码不正确';
            return errorMsg;
        };   

        var pwd = $('#login_pwd').val();    
        if (pwd.length < 6) {        
            $('#login_pwd').focus();
            errorMsg = '密码长度不足';
            return errorMsg;
        };        
        errorMsg = '';
        return errorMsg;
    }

    var config = {
    regApi:''
    }

    return {
        data:{

        },
        init:function(_config) {
            Util.mixin(config,_config);//将传入的配置混合到本地
            this._bind(); 
        },
        _bind:function() {
            //登陆提交绑定
            $('#login_submit').bind('click', function () {
                var errorMsg = checkLoginForm();
                if (errorMsg.length > 0) {
                    alert(errorMsg);                   
                } else {
                    var url = host + 'j_spring_security_check';
                    var formdata = $('#login_form').serialize();            
                    $.ajax({
                        type: 'POST',
                        url: url,                        
                        data: formdata,     
                        dataType:'json',                   
                        success:function (data) {
                        	if (data.errorMessage.length == 0) {
                        		$.mobile.changePage('main.html');
                        		$.ajax({
                        			type:'GET',
                        			url:host+'yushouAppAction/validRecommendUser.json',
                        			success:function(data){
                        				console.log(data);
                        			}
                        		});
                        	}
                        	else {
                        		alert(data.errorMessage);
                        	}
                        	
                        },
                        error:function (error) {
                        	alert('error::' + error);
                        }
                    });
                }
            });
        },
        clearAll:function(){
            this.data = {};
        }
    }

}();

/*
*popularize_vin.html
*/
var popVin = function() {

    var config = {
        regApi:''
    };
    return {
        data:{

        },

        init:function(_config) {
            Util.mixin(config,_config);//将传入的配置混合到本地
            this._bind(); 
        },

        _bind:function() {
            //加载匹配车型
            $('#searchvin').bind('click', function () {
                var vinNum = $('#vin').val().toUpperCase();
                if (vinNum.length != 17) {
                    alert('vin error');
                    $('#vin').focus();
                    // navigator.notification.alert(
                    //     'vin error',  // message
                    //     null,         // callback
                    //     'error title',            // title
                    //     'Done'                  // buttonName
                    // );
                }
                else {
                    var url = host + 'carBasicAction/getVin.json';
                    var formdata = 'carjianumber-select=' + vinNum;
                    $.ajax({
                        type: 'POST',
                        url: url,
                        data: formdata, 
                        dataType:'json',                       
                        success: function (data) {       
							if (data.number < 1) {
								popDetailB.data = {vin: vinNum};
                            	$.mobile.changePage( "popularize-detail-b.html");
							} else {
								popDetailA.data = {vin: vinNum, data: data};
	                            $.mobile.changePage( "popularize-detail-a.html");	
							}
							
                            
                        },
                        error: function (error) {

                        }
                    });
                }
            });
        },

        clearAll:function() {
            this.data = {};
        }
    }
}();

/*
*popularize-detail-a.html
*/

var popDetailA = function() {

    function checkPopDetailA() {

        var errorMsg;

        var brand = $('#a_brand').val();
        if (brand.length < 1) {
        	errorMsg = 'brand error';
        	return errorMsg;
        };

        var series = $('#a_series').val();
        if (series.length < 1) {
        	errorMsg = 'series error';
        	return errorMsg;
        };

        var model = $('#model').val();
        if (model.length < 1) {
            errorMsg = 'model error';
            $('#model').focus();
            return errorMsg;
        };

        var registerDate = $('#registerDate').val();
        if (registerDate.length < 1) {
            errorMsg = 'registerDate error';
            $('#registerDate').focus();
            return errorMsg;
        };

        var mile = $('#mile').val();
        if (mile.length < 1) {
            errorMsg = 'mile error';
            $('#mile').focus();
            return errorMsg;
        };

        var province = $('#province').val();
        if (province.length < 1) {
            errorMsg = 'province error';
            $('#province').focus();
            return errorMsg;
        };

        var city = $('#city').val();
        if (city.length < 1) {
            errorMsg = 'city error';
            $('#city').focus();
            return errorMsg;
        };

        var price = $('#price').val();
        if (price.length < 1) {
            errorMsg = 'price error';
            $('#price').focus();
            return errorMsg;
        };

        var level = $('#level').val();
        if (level.length < 1) {
            errorMsg = 'level error';
            $('#level').focus();
            return errorMsg;
        };

        var period = $('#period').val();
        if (period.length < 1) {
            errorMsg = 'period error';
            $('#period').focus();
            return errorMsg;
        };

        errorMsg='';
        return errorMsg;
    }

    var config = {
        regApi:''
    }

    return {
        data: {

        },

        init: function(_config) {
            Util.mixin(config, _config);
            this._bind();
        },

        _bind: function() {
            //vin brand series model            
            $('#vinNum').text(this.data.vin);                        

            var contentData = this.data.data.list;
            // var contentData = [{brand:0,series:0,brandName:'haha',seriesName:'hehe',model:'model1',modelName:'modelName1'}
            // ,{brand:1,series:1,brandName:'haha1',seriesName:'hehe1',model:'model2',modelName:'modelName2'}];
            if (contentData !== undefined) {
            	var firstData = contentData[0];
	            $('.brand').text(firstData.brandName);
	            $('.series').text(firstData.seriesName);
	            $('#a_brand').val(firstData.brand);
	            $('#a_series').val(firstData.series);


	            var layout = [];
	            for (var i = 0, len = contentData.length; i < len; i++) {  
	            	var item = contentData[i];
	            	layout.push('<label>\
	            		<input type="radio" name="model" id="model" required="true" value="' + item.model + '" />\
	            		' + item.modelName + '</label>');              
	            }                    
	            $('#carsinfo').html(layout.join(''));
	            $('#carsinfo').show();                    
            }

            //加载省信息            
            var url = host + 'dicAction/loadRootLevel.json';   
            var requestData = 'request_message={"type":"area"}';     
            $.ajax({
                type: 'POST',
                url: url,            
                dataType:'json',
                data: requestData,
                success: function (data) {
                     var layout = '<option data-placeholder="true" value="">选择省份</option>';
                     var listData = data.items; 
                     if (listData !== undefined) {
                     	for (var i = 0, len = listData.length; i < len; i++) {
                     		var item = listData[i];
	                     	layout += '<option value="' + item.code + '">'+ item.name+'</option>';
	                     }
	                     $('#province').html(layout);
	                     $('#province').selectmenu('refresh', true);
                     }
                     
                },
                error: function (error) {

                }
            });

            //加载市信息
            $('#province').bind('change', function() {
            	var url = host + 'dicAction/loadNextLevel.json';
            	var prov = $('#province').val();
            	var requestData = 'request_message={"code":"'+ prov +'","type":"area"}';
            	$.ajax({
            		type: 'POST',
	                url: url,            	                
	                dataType:'json',
	                data: requestData,
	                success: function (data) {
	                     var layout = '<option data-placeholder="true" value="">选择城市</option>';
	                     var listData = data.items; 
	                     if (listData !== undefined) {
	                     	for (var i = 0, len = listData.length; i < len; i++) {
		                     	var item = listData[i];
		                     	layout += '<option value="' + item.code + '">'+ item.name+'</option>';
		                     }
		                     $('#city').html(layout);
		                     $('#city').selectmenu('refresh', true);	
	                     };	                     
	                },
	                error: function (error) {

	                }
            	});
            });

			//加载评级
			var pjUrl = host + 'dicAction/loadRootLevel.json?request_message={"type":"carcaption"}';
			$.ajax({
				type: 'GET',
                url: pjUrl,            
                dataType:'json',                
                success: function (data) {
                     var layout = '<option data-placeholder="true" value="">选择车辆评级</option>';
                     var listData = data.items; 
                     if (listData !== undefined) {
                     	for (var i = 0, len = listData.length; i < len; i++) {
                     		var item = listData[i];
	                     	layout += '<option value="' + item.code + '">'+ item.name+'</option>';
	                     }
		                     $('#level').html(layout);
		                     $('#level').selectmenu('refresh', true);
                     }
                     
                }
			});

			//加载周期
			var zqUrl = host + 'dicAction/loadRootLevel.json?request_message={"type":"tradeperiod"}';
			$.ajax({
				type: 'GET',
                url: zqUrl,            
                dataType:'json',                
                success: function (data) {
                     var layout = '<option data-placeholder="true" value="">期望预售周期</option>';
                     var listData = data.items; 
                     if (listData !== undefined) {
                     	for (var i = 0, len = listData.length; i < len; i++) {
                     		var item = listData[i];
	                     	layout += '<option value="' + item.code + '">'+ item.name+'</option>';
	                     }
	                     $('#period').html(layout);
	                     $('#period').selectmenu('refresh', true);
                     }
                     
                }
			});

            $('#pop_detail_a_submit').bind('click',function(e) {
            	e.preventDefault()
                var registerDate = $('#registerDate').val();                
                var mile = $('#mile').val();                
                var province = $('#province').val();
                var city = $('#city').val();                
                var price = $('#price').val();                
                var level = $('#level').val();                
                var period = $('#period').val();                
                var model = $('#model').val();
                var brand = $('#a_brand').val();
                var series = $('#a_series').val();

                var vin = $('#vinNum').text();

                popPhoto.data = {vin:vin,
                	registerDate:registerDate,
                	mile:mile,
                	province:province,
                	city:city,
                	price:price,
                	level:level,
                	period:period,
                	model:model,
                	brand:brand,
                	series:series,
                	fromSrc:'popularize-detail-a.html'};

                $.mobile.changePage('popularize-photo.html');
                return false;
            });           
        },

        clearAll:function() {
            this.data = {};
        }
    }
}();

/*
*popularize-detail-b
*/
var popDetailB = function() {

    function checkPopDetailB() {

        var errorMsg;

        var brand = $('#nore_brand').val();
        if (brand.length < 1) {
        	errorMsg = 'brand error';
        	return errorMsg;
        };

        var series = $('#nore_series').val();
        if (series.length < 1) {
        	errorMsg = 'series error';
        	return errorMsg;
        };
        
        var model = $('#nore_model').val();
        if (model.length < 1) {
            errorMsg = 'model error';          
            return errorMsg;
        };

        var registerDate = $('#nore_registerDate').val();
        if (registerDate.length < 1) {
            errorMsg = 'registerDate error';
            $('#nore_registerDate').focus();
            return errorMsg;
        };

        var mile = $('#nore_mile').val();
        if (mile.length < 1) {
            errorMsg = 'mile error';
            $('#nore_mile').focus();
            return errorMsg;
        };

        var province = $('#nore_province').val();
        if (province.length < 1) {
            errorMsg = 'province error';
            $('#nore_province').focus();
            return errorMsg;
        };

        var city = $('#nore_city').val();
        if (city.length < 1) {
            errorMsg = 'city error';
            $('#nore_city').focus();
            return errorMsg;
        };

        var price = $('#nore_price').val();
        if (price.length < 1) {
            errorMsg = 'price error';
            $('#nore_price').focus();
            return errorMsg;
        };

        var level = $('#nore_level').val();
        if (level.length < 1) {
            errorMsg = 'level error';
            $('#nore_level').focus();
            return errorMsg;
        };

        var period = $('#nore_period').val();
        if (period.length < 1) {
            errorMsg = 'period error';
            $('#nore_period').focus();
            return errorMsg;
        };

        errorMsg='';
        return errorMsg;
    }

    var config = {
        regApi:''
    };

     // var indexnum = 0;
    return {
        data: {

        },

        init: function(_config) {
            Util.mixin(config, _config);
            this._bind();            
        },

        _bind: function() {
     //    	if (indexnum === 0) {
     //    		this.data = {
					// 	canModify : 'status',
					// 	carId : 	'20023f73-7e2a-4b3b-8c1f-90f2c1297e23'
					// };		
     //    		indexnum =1;
     //    	};
			var canModify = this.data.canModify;
			var carId = this.data.carId;
			if (canModify) {

				//修改返回路径
				$('#pop_detail_b_back').attr('href','MySecondHandCar.html');

				//修改传递参数
				$('#nore_brand_series_model').bind('click',function(e){	
					var registerDate = $('#nore_registerDate').val();                
	                var mile = $('#nore_mile').val();                
	                var province = $('#nore_province').val();
	                var city = $('#nore_city').val();                
	                var price = $('#nore_price').val();                
	                var level = $('#nore_level').val();                
	                var period = $('#nore_period').val();                
	                var vin = $('#vin_no_result').text();
	                var model = $('#nore_model').val();
	                var brand = $('#nore_brand').val();
	                var series = $('#nore_series').val();
	                
	                var curData = {carId:carId,
	                	vin:vin,
	                	registerDate:registerDate,
	                	mile:mile,
	                	province:province,
	                	city:city,
	                	price:price,
	                	level:level,
	                	period:period,
	                	model:model,
	                	brand:brand,
	                	series:series,
	                	fromSrc:'popularize-detail-b.html'};
	                
					BrandSelector.data = {canModify:curData};	
					$.mobile.changePage ('brand.html');
					// this.data = {vin:vin};				
				});
				
				if (canModify.carId) {

					var carModel = this.data.carModelId;
					
		            if (carModel) {
		            	var carModelName = this.data.carModelName;
		            	var carSeries = this.data.carSeriesId;
		            	var carSeriesName = this.data.carSeriesName;
		            	var carBrand = this.data.carBrandId;
		            	var carBrandName =this.data.carBrandName;

		            	$('#nore_brand_series_model').html('<label>'+carBrandName + '</label><label>' + carSeriesName + '</label><label>' + carModelName+'</label>');
		            	$('#nore_brand').val(carBrand);
		            	$('#nore_series').val(carSeries);
		            	$('#nore_model').val(carModel);            	
		            };
					$('#vin_no_result').text(canModify.vin);        			        			
					$('#nore_registerDate').val(canModify.registerDate);        
					$('#nore_mile').val(canModify.mile);

					$('#nore_province option[value="'+canModify.province+'"]').prop('selected',true);

			      	
			       	$('#nore_price').val(canModify.price);			

			       	$('#nore_level option[value="'+canModify.carCaption+'"]').prop('selected',true);
			      	$('#nore_period option[value="'+canModify.tradePeriod+'"]').prop('selected',true);		        
			      	
			      	$('#popularize-detail-b select').selectmenu('refresh');

			        $('#noe_carId').val(canModify.carId);			        
			        $('#nore_pic1').val(canModify.pic1);
			        $('#nore_pic2').val(canModify.pic2);
			        $('#nore_pic3').val(canModify.pic3);
			        $('#nore_pic4').val(canModify.pic4);
			        $('#nore_pic5').val(canModify.pic5);
			        $('#nore_pic6').val(canModify.pic6);
			        //加载对应的城市信息
			        var url = host + 'dicAction/loadNextLevel.json';
	            	var prov = $('#nore_province').val();
	            	var requestData = 'request_message={"code":"'+ prov +'","type":"area"}';
	            	var cityinfo = canModify.city;
	            	$.ajax({
	            		type: 'POST',
		                url: url,            
		                async: true,
		                dataType:'json',
		                data: requestData,
		                success: function (data) {
		                     var layout = '<option data-placeholder="true" value="">选择城市</option>';
		                     var listData = data.items; 
		                     if (listData !== undefined) {
		                     	for (var i = 0, len = listData.length; i < len; i++) {
			                     	var item = listData[i];
			                     	layout += '<option value="' + item.code + '">'+ item.name+'</option>';
			                     }
			                     $('#nore_city').html(layout);
			                     $('#nore_city').selectmenu('refresh', true);	
			                     $('#nore_city option[value="'+cityinfo+'"]').prop('selected',true);
			                     $('#nore_city').selectmenu('refresh');
		                     };	                     
		                },
		                error: function (error) {

		                }
	            	}); 
				}
				else {
					$.ajax({
						type: 'GET',
	                	url: host + 'yushouAppAction/getDetailYushouCar.json?carId=' + this.data.carId,            
	                	async: true,
	                	dataType:'json',
	                	success: function (data) {
	                		if (Util.isLogin(data.errorMessage)) {
	                			
	                			$('#vin_no_result').text(data.carjiaNumber);
	                			
	                			$('#nore_brand_series_model').html('<label>'+data.brandName + '</label><label>' + data.seriesName +'</label><label>' + data.modelName+'</label>');
	                			$('#nore_brand').val(data.brand);
				            	$('#nore_series').val(data.series);
				            	$('#nore_model').val(data.model);
								$('#nore_registerDate').val(data.registerDate);        
	        					$('#nore_mile').val(data.milege);
	        					$('#nore_province option[value="'+data.province+'"]').prop('selected',true);						      				        
						       	$('#nore_price').val(data.price);					        
						       	
						      	$('#nore_level option[value="'+data.carCaption+'"]').prop('selected',true);
						      	$('#nore_period option[value="'+data.tradePeriod+'"]').prop('selected',true);
						        
						        $('#popularize-detail-b select').selectmenu('refresh');
						        $('#nore_carId').val(data.carId);
						        $('#nore_pic1').val(data.pic1);
						        $('#nore_pic2').val(data.pic2);
						        $('#nore_pic3').val(data.pic3);
						        $('#nore_pic4').val(data.pic4);
						        $('#nore_pic5').val(data.pic5);
						        $('#nore_pic6').val(data.pic6);
						        //加载对应的城市信息
						        var url = host + 'dicAction/loadNextLevel.json';
				            	var prov = $('#nore_province').val();
				            	var requestData = 'request_message={"code":"'+ prov +'","type":"area"}';
				            	var cityinfo = data.city;
				            	$.ajax({
				            		type: 'POST',
					                url: url,            
					                async: true,
					                dataType:'json',
					                data: requestData,
					                success: function (data) {
					                     var layout = '<option data-placeholder="true" value="">选择城市</option>';
					                     var listData = data.items; 
					                     if (listData !== undefined) {
					                     	for (var i = 0, len = listData.length; i < len; i++) {
						                     	var item = listData[i];
						                     	layout += '<option value="' + item.code + '">'+ item.name+'</option>';
						                     }
						                     $('#nore_city').html(layout);						                     
						                     $('#nore_city').selectmenu('refresh', true);	
						                     $('#nore_city option[value="'+cityinfo+'"]').prop('selected',true);
						                     $('#nore_city').selectmenu('refresh');
					                     };	                     
					                },
					                error: function (error) {

					                }
				            	});   
	                		};
	                	}
					});
				}
				
			}	
			else {				
				//vin
	            $('#vin_no_result').text(this.data.vin);

	            var carModel = this.data.carModelId;
	            if (carModel) {
	            	var carModelName = this.data.carModelName;
	            	var carSeries = this.data.carSeriesId;
	            	var carSeriesName = this.data.carSeriesName;
	            	var carBrand = this.data.carBrandId;
	            	var carBrandName =this.data.carBrandName;

	            	$('#nore_brand_series_model').html('<label>'+carBrandName + '</label><label>' + carSeriesName + '</label><label>' + carModelName+'</label>');
	            	
	            	$('#nore_brand').val(carBrand);
	            	$('#nore_series').val(carSeries);
	            	$('#nore_model').val(carModel);            	
	            };
			}
            
           
            //加载省信息            
            var url = host + 'dicAction/loadRootLevel.json';   
            var requestData = 'request_message={"type":"area"}';     
            $.ajax({
                type: 'POST',
                url: url,            
                async: true,
                dataType:'json',
                data: requestData,
                success: function (data) {
                     var layout = '<option data-placeholder="true" value="">选择省份</option>';
                     var listData = data.items; 
                     if (listData !== undefined) {
                     	for (var i = 0, len = listData.length; i < len; i++) {
                     		var item = listData[i];
	                     	layout += '<option value="' + item.code + '">'+ item.name+'</option>';
	                     }
	                     $('#nore_province').html(layout);
	                     $('#nore_province').selectmenu('refresh', true);	
                     };                     
                },
                error: function (error) {

                }
            });


            //加载市信息          

        	$('#nore_province').bind('change', function() {
            	var url = host + 'dicAction/loadNextLevel.json';
            	var prov = $('#nore_province').val();
            	var requestData = 'request_message={"code":"'+ prov +'","type":"area"}';
            	$.ajax({
            		type: 'POST',
	                url: url,            
	                async: true,
	                dataType:'json',
	                data: requestData,
	                success: function (data) {
	                     var layout = '<option data-placeholder="true" value="">选择城市</option>';
	                     var listData = data.items; 
	                     if (listData !== undefined) {
	                     	for (var i = 0, len = listData.length; i < len; i++) {
		                     	var item = listData[i];
		                     	layout += '<option value="' + item.code + '">'+ item.name+'</option>';
		                     }
		                     $('#nore_city').html(layout);
		                     $('#nore_city').selectmenu('refresh', true);	
	                     };	                     
	                },
	                error: function (error) {

	                }
            	});
        	});
            
            

			//加载评级
			var pjUrl = host + 'dicAction/loadRootLevel.json?request_message={"type":"carcaption"}';
			$.ajax({
				type: 'GET',
                url: pjUrl,            
                dataType:'json',                
                success: function (data) {
                     var layout = '<option data-placeholder="true" value="">选择车辆评级</option>';
                     var listData = data.items;                      
                     if (listData !== undefined) {
                     	for (var i = 0, len = listData.length; i < len; i++) {
                     		var item = listData[i];
	                     	layout += '<option value="' + item.code + '">'+ item.name+'</option>';
	                     }
	                     $('#nore_level').html(layout);
	                     $('#nore_level').selectmenu('refresh', true);	                                       
                     }
                     
                }
			});

			//加载周期
			var zqUrl = host + 'dicAction/loadRootLevel.json?request_message={"type":"tradeperiod"}';
			$.ajax({
				type: 'GET',
                url: zqUrl,            
                dataType:'json',                
                success: function (data) {
                     var layout = '<option data-placeholder="true" value="">期望预售周期</option>';
                     var listData = data.items; 
                     if (listData !== undefined) {
                     	for (var i = 0, len = listData.length; i < len; i++) {
                     		var item = listData[i];
	                     	layout += '<option value="' + item.code + '">'+ item.name+'</option>';
	                     }
	                     $('#nore_period').html(layout);
	                     $('#nore_period').selectmenu('refresh', true);
                     }
                     
                }
			});

            $('#pop_detail_b_submit').bind('click',function(e) {
            	e.preventDefault();
            	e..stopPropagation();
                var registerDate = $('#nore_registerDate').val();                
                var mile = $('#nore_mile').val();                
                var province = $('#nore_province').val();
                var city = $('#nore_city').val();                
                var price = $('#nore_price').val();                
                var level = $('#nore_level').val();                
                var period = $('#nore_period').val();                

                var vin = $('#vin_no_result').text();

                var model = $('#nore_model').val();
                var brand = $('#nore_brand').val();
                var series = $('#nore_series').val();
                var carId = $('#nore_carId').val();
                var pic1 = $('#nore_pic1').val();
		        var pic2 = $('#nore_pic2').val();
		        var pic3 = $('#nore_pic3').val();
		        var pic4 = $('#nore_pic4').val();
		        var pic5 = $('#nore_pic5').val();
		        var pic6 = $('#nore_pic6').val();
                popPhoto.data = {carId:carId,
                	vin:vin,
                	registerDate:registerDate,
                	mile:mile,
                	province:province,
                	city:city,
                	price:price,
                	level:level,
                	period:period,
                	model:model,
                	brand:brand,
                	series:series,
                	pic1:pic1,
                	pic2:pic2,
                	pic3:pic3,
                	pic4:pic4,
                	pic5:pic5,
                	pic6:pic6,
                	fromSrc:'popularize-detail-b.html'};

                $.mobile.changePage('popularize-photo.html');
                return false;
            });           

        },

        clearAll:function() {
            this.data = {};
        }
    }
}();

/*
*popularize-photo
*/
var popPhoto = function() {

    var config = {
        regApi:''
    }    

    var pictureSource;   // picture source
    var destinationType; // sets the format of returned value

    function onDeviceReady() {
        pictureSource=navigator.camera.PictureSourceType;
        destinationType=navigator.camera.DestinationType;
    }

    function Uploader (id) {
    	showConfirm();
    	function showConfirm() {
	        navigator.notification.confirm(
	            '请横屏拍摄图片！', // message
	             onConfirm,            // callback to invoke with index of button pressed
	            '上传图片',           // title
	            '拍照,选择图片'         // buttonLabels
	        );
	    }

        function onConfirm(buttonIndex) {
	        if (buttonIndex == 1) {
	            navigator.camera.getPicture(onGetPicSuccess, onGetPicFail, { quality: 30,
	                destinationType: destinationType.FILE_URI });
	        } else {
	            navigator.camera.getPicture(onGetPicSuccess, onGetPicFail, { quality: 30,
	                destinationType: destinationType.FILE_URI,
	                sourceType: pictureSource.PHOTOLIBRARY});
	        }
	    }

	    function onGetPicSuccess(imageSrc) {
	        var pic = $('#' + id + 'Image');
	        pic.attr('src',imageSrc);
	        pic.css('display','block');
	        var options = new FileUploadOptions();
	        options.fileKey="file";
	        options.fileName=imageSrc.substr(imageSrc.lastIndexOf('/')+1);
	        options.mimeType="image/jpeg";

	        var params = new Object();	        
            params.name = 'picture:yushou:230,270,325,700';
	        options.params = params;

	        var ft = new FileTransfer();
	        ft.upload(imageSrc, host + "yushouAppAction/uploadImage.upload", onUploadSuccess, onUploadFail, options);
	    }


	    function onGetPicFail(error) {
	        alert('Failed because: ' + error);
	    }

	    function onUploadSuccess(r) {
            var jsonData = JSON.parse(r.response);
	    	var hidePic = $('#' + id + 'Pic');
	    	hidePic.val(jsonData.path);
//	        alert("Code = " + r.responseCode + " Response = " + r.response + " Sent = " + r.bytesSent + " path = " + jsonData.path);
	    }

	    function onUploadFail(error) {
	        alert("An error has occurred: Code = " + error.code + " upload error source " + error.source + " upload error target " + error.target);        
	    }
    }

    function checkImages() {
    	if ($('#45frontChoosePic').val().length < 1 || $('#45behindChoosePic').val().length < 1 || $('#sideChoosePic').val().length < 1
    		|| $('#centerChoosePic').val().length < 1 || $('#backChoosePic').val().length < 1 || $('#cardChoosePic').val().length < 1) {

    		return false;
    	};

    	return true
    }
    


    return {
        data:{},
        init:function(_config) {
            Util.mixin(config, _config);
            this._bind();
        },
        _bind:function() {
        	
        	$('#ph_vin').val(this.data.vin);
        	$('#ph_registerDate').val(this.data.registerDate);
        	$('#ph_mile').val(this.data.mile);
        	$('#ph_province').val(this.data.province);
        	$('#ph_city').val(this.data.city);
        	$('#ph_price').val(this.data.price);
        	$('#ph_level').val(this.data.level);
        	$('#ph_period').val(this.data.period);
        	$('#ph_model').val(this.data.model);
        	$('#ph_brand').val(this.data.brand);
        	$('#ph_series').val(this.data.series);
        	if (this.data.carId) {
        		$('#ph_carId').val(this.data.carId);
        		$('#45frontChoosePic').val(this.data.pic1);
        		$('#45behindChoosePic').val(this.data.pic2);
        		$('#sideChoosePic').val(this.data.pic3);
        		$('#centerChoosePic').val(this.data.pic4);
        		$('#backChoosePic').val(this.data.pic5);
        		$('#cardChoosePic').val(this.data.pic6);

        		$('#45frontChooseImage').attr('src',this.data.pic1);
        		$('#45frontChooseImage').css('display','block');

        		$('#45behindChooseImage').attr('src',this.data.pic2);
        		$('#45behindChooseImage').css('display','block');

        		$('#sideChooseImage').attr('src',this.data.pic3);
        		$('#sideChooseImage').css('display','block');

        		$('#centerChooseImage').attr('src',this.data.pic4);
        		$('#centerChooseImage').css('display','block');

        		$('#backChooseImage').attr('src',this.data.pic5);
        		$('#backChooseImage').css('display','block');

        		$('#cardChooseImage').attr('src',this.data.pic6);
        		$('#cardChooseImage').css('display','block');
        		
        	}
        	


        	$('#ph_fromsrc').attr('href',this.data.fromSrc);

            document.addEventListener("deviceready", onDeviceReady, false);

            $('.imageUpload').bind('click', function (e) {
            	var elementId = $(this).attr('id');
            	new Uploader(elementId);
            	return false;
            });

            $('#pop-success-submit').bind('click', function(){
            	if (checkImages()) {
            		var url = host + 'yushouAppAction/submitYushouCar.json';
            		var formdata = $('#ph_form').serialize();                        
                    $.ajax({
                        type: 'POST',
                        url: url,                        
                        data: formdata,    
                        dataType:'json',                    
                        success:function (data) {
                        	alert('data::'+ data.errorMessage);
                        	if (Util.isLogin(data.errorMessage)) {
                        		$.mobile.changePage('popularize-success.html');
                        	}                        	
                        },
                        error:function (error) {
                        	alert('error::'+ error);
                        }
                    });
            	} else {
            		alert('请检查图片是否缺少，图片正在上传中..');
            	}
              return false;
            });
        },

        clearAll: function() {
            this.data = {};
        }
    }
}();


var BrandSelector = function(){
	var ZIMU = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
	ZIMU = ZIMU.split("");
	var datas = {
			
	}
	var getExt = function(extString){
		var arr1 = extString.split(", ")
		var result = {}
		arr1.forEach(function(a){
			var arr2 = a.split("=")
			result[arr2[0]]=arr2[1]
		})
		return result;
	}
    var config = {
      api_brands:"",
      event_click:null
    }
    return {
      data:{
        selectedBrandCode:null
      },
      event:{
        clickEvent:null
      },
      init:function(_config){
        Util.mixin(config,_config);
       
        var self = this ;
      //   $.mobile.loading( "show", {
      //     text: "Loading",
      //     textVisible: true
      // });
        Util.showLoadingView(true,"加载品牌信息中");
        Util.ajax({
          url:host + config.api_brands,
          type:"GET",
          dataType:"json",
          success:function(data){
        	  Util.showLoadingView(false,"加载品牌信息中");
            if(data.errorMessage){
              alert("加载品牌信息出错:"+data.errorMessage)
            }else{
              self._create(data)
            }
            
          },
          error:function(error){
        	  Util.showLoadingView(false,"加载品牌信息中");
            alert("加载品牌信息出错")
          }
        })
      },
      _create:function(brands){
    	
    	brands.items.forEach(function(brand){
    		var zimu = brand.name.charAt(0);
    		
    		
            datas[zimu] = datas[zimu] || []
    		datas[zimu].push(brand)
    	})
    	ZIMU.forEach(function(zimu){
    		if(!datas[zimu]) return;

    		$("#brand_selector .list").append('<li class="list-splider" data-id="splider-'+zimu+'">'+zimu+'</li>')
    		datas[zimu].forEach(function(brand){
    			var ext = getExt(brand.extString)



                $("#brand_selector .list").append('<li class="brand-item" data-brandCode="'+brand.code+'" data-brandName="'+brand.name+'" data-brandUrl="'+ ext.picture +'"><img src="'+ext.picture+'"/></li>')
             
    		})
    		 $("#brand_selector .list").append('<li class="list-clear"></li><li class="list-border"></li>')
    	})
        
        this._bind();
      },
      _bind:function(){
      	var brandselectCanModify = this.data.canModify;
        var self = this;
        $("#brand_selector .list .brand-item").click(function(){
        	var brandCode = $(this).attr('data-brandCode');
        	var brandName = $(this).attr('data-brandname');
        	var brandUrl = $(this).attr('data-brandUrl');        	
        	xuanZeKuanShi.data = {brandCode:brandCode,brandName:brandName,brandUrl:brandUrl, canModify:brandselectCanModify};
        	$.mobile.changePage('xuanZeKuanShi.html');
        	// alert('brandCode::'+brandCode+' brandName::'+brandName+' brandUrl::'+brandUrl)
          // self.data.selectedBrandCode = $(this).attr("data-brandCode")
          // config.event_click&&config.event_click();

        })
        $("#brand_selector  .quickbar-item").bind("tap",function(){
          var zimu = $(this).html();
          $("#brand_selector  .quickbar-item").removeClass("active")
          $(this).addClass("active")
          $("html,body").scrollTop($("#brand_selector li[data-id=splider-"+zimu+"]").offset().top)
        })
        $("#brand_selector .quick-bar").bind("vmousemove",function(e){
          e.stopPropagation();
        })
      }
    }
}();


var LoginOrReg = function(){
	var reCount = function(){
		var windowW = $(window).width();
		var itemW = windowW/6;
		$("#loginorreg .logo").css({
			top:itemW*2.3,
			left:itemW*1.2,
			width:itemW*3.7
		})
		$("#loginorreg .yushou").css({
			top:itemW*1.8,
			right:itemW*0.6,
		})
		$("#loginorreg .reg").css({
			top:itemW*4.8,
			left:itemW*1.2,
			width:itemW*3.6,
			height:itemW*1.1,
			'lineHeight':itemW*1.1+"px"
		})
		$("#loginorreg .login").css({
			top:itemW*6,
			left:itemW*1.2,
			width:itemW*3.6,
			height:itemW*1.1,
			'lineHeight':itemW*1.1+"px"
		})
	}
	return{
		init:function(){
			reCount();
			$(window).resize(reCount);
		}
	}
}();

var Splash = function(){
	return{
		init:function(){
			//判断用户是否登录
			// $( "body" ).on( "pageload", function( event, ui ) {
				setTimeout(function(){
					$.ajax({
						url:host + 'yushouAppAction/isLogin.json',
				        type:"GET",
				        dataType:"json",
				        success:function(data){
				        	if (!DEBUG) {			        	
					      	    if(data.errorMessage && data.errorMessage == '未登录用户') {			      	    
				      	    		$.mobile.changePage('html/loginorreg.html');			      	 
					      	    } else {			      	 
				      	    		$.mobile.changePage('html/main.html');
					      	    }
				      		}

				        },
				        error:function(error){
				   	        
				        }
					});
				},1500); 
  				
			// });
			
		}
	}
}();

var Main = function(){
	var reCount = function(){
		var windowW = $(window).width();
		var itemW = windowW/7;
		$("#main .main1").css({
			top:itemW*1.16,
			left:itemW*1.2,
			width:itemW*2.23,
			height:itemW*2.23
		})
		$("#main .main2").css({
			top:itemW*4.66,
			left:itemW*2.4,
			width:itemW*2.23,
			height:itemW*2.23
		})
		$("#main .main3").css({
			top:itemW*8.2,
			left:itemW*3.6,
			width:itemW*2.23,
			height:itemW*2.23
		})
		$("#main .main4").css({
			top:itemW*8.16,
			left:itemW*1.2,
			width:itemW*1.1,
			height:itemW*1.1
		})
		$("#main .main5").css({
			top:itemW*9.36,
			left:itemW*1.2,
			width:itemW*1.1,
			height:itemW*1.1
		})
	}
	return{
		init:function(){
			reCount();
			$(window).resize(reCount);			
		}
	}
}();

var Share = function(){
	
	return {
		init:function(){
			$("#share_sms").click(function(){
				cordova.exec(function(winParam) {
					Util.showLoadingView(true,"信息发送中")
					if(winParam){
						$.ajax({
							url:host + "yushouAppAction/sendSpreadMessage.json",
							success:function(){
								alert("发送成功！");
								Util.showLoadingView(false,"信息发送中")
							},
							type:"POST",
							data:{
								phone:winParam.replace(/[^0-9]/g,""),
								debug:true,
								phoneType:device.platform.toLowerCase()
							},
							error:function(){
								alert("系统错误！")
								Util.showLoadingView(false,"信息发送中")
							}
						})
					}else{
						alert("系统错误！")
					}
					
				}, function(error) {}, "Souche",
			            "sms", ["firstArgument", "secondArgument", 42,
			                    false]);
			})
		}
	}
}();
var FriendSelector = function(){
    var config = {
      api_brands:"",
      event_change:null,
      event_submit:null
    }

    var countFriend = function(){
      var selectedPhones = []
      $("#friend_selector .brand-item input[type=checkbox]").each(function(i,checkbox){
        if(checkbox.checked){
          selectedPhones.push($(checkbox).attr("data-phone"))
        }
      })
      return selectedPhones;
    }
    return {
      data:{
        selectedPhones:[] //选中的好友的手机号们
      },
      event:{
        clickEvent:null
      },
      init:function(_config){
        Util.mixin(config,_config);
        var self = this ;
      //   $.mobile.loading( "show", {
      //     text: "Loading",
      //     textVisible: true
      // });
        Util.ajax({
          url:config.api_brands,
          type:"GET",
          dataType:"json",
          success:function(data){
            if(data.errorMessage){
              alert("加载品牌信息出错:"+data.errorMessage)
            }else{
              self._create(data)
            }
          },
          error:function(error){
            alert("加载品牌信息出错")
          }
        })
      },
      _create:function(brands){
        for(var zimu in brands){
          _brands = brands[zimu]
          $("#friend_selector .list").append('<li class="list-splider" data-id="splider-'+zimu+'">'+zimu+'</li>')
          for(var brandId in _brands){
            brand = _brands[brandId]
            $("#friend_selector .list").append('<li class="brand-item" data-brandId="'+brandId+'"><input type="checkbox" name="ddd" id="friend-checkbox-'+brandId+'" data-phone="'+brand.phone+'"/><label for="friend-checkbox-'+brandId+'">'+brand.name+'</label></li>')
          
          }
          $("#friend_selector .list").append('<li class="list-clear"></li>')
        }
        this._bind();
      },
      _bind:function(){
        var self = this;
        $("#friend_selector").trigger('create')
        $("#friend_selector .tool-bar button").button( "disable" );
        $("#friend_selector .tool-bar button").click(function(){
          config.event_submit&&config.event_submit();
        })
        $("#friend_selector .brand-item input[type=checkbox]").bind("change",function(){
          
          self.data.selectedPhones = countFriend();
          $("#friend_selector .count em").html(self.data.selectedPhones.length)
          if(self.data.selectedPhones.length==0){
            $("#friend_selector .tool-bar button").button( "disable" );
          }else{
            $("#friend_selector .tool-bar button").button( "enable" );
          }
          config.event_change&&config.event_change();
        })

        $("#friend_selector  .quickbar-item").bind("tap",function(){
          var zimu = $(this).html();
          $("#friend_selector  .quickbar-item").removeClass("active")
          $(this).addClass("active")
          $("html,body").animate({
            scrollTop:$("#friend_selector li[data-id=splider-"+zimu+"]").offset().top
          })
        })
        $("#friend_selector .quick-bar").bind("vmousemove",function(e){
          e.stopPropagation();
        })
      }
    }
}();


