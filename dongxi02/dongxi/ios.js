$(document).ready(function(){
	var host = document.location.host;
	topicId = GetQueryString("topic");
	$("header").css("display","none");
	$("#goListBtn").hide();
	URL_DETAILS='dongxiapp://'+host+'/discuss/question/info?question=';
	URL_REPLY='dongxiapp://'+host+'/discuss/answer/info?answer=';
	URL_INDEX='dongxiapp://'+host+'/discuss/question/list?topic=';
	var URL_PROFILE='dongxiapp://'+host+'/discuss/profile/info?uid=';
	$(".questionListSubmitIpt textarea").focus(function() {
		$(".submitBtn").css("bottom","300px");
	});
	$(".questionListSubmitIpt textarea").blur(function() {
		$(".submitBtn").css("bottom","0");
	});
	$(".main").on("click",".user img",function(){
		location.href=URL_PROFILE+$(this).data('uid');
	});
	$(".main").on("click",".user2 img",function(){
		location.href=URL_PROFILE+$(this).data('uid');
	});
	$(".main").on("click",".d2-p1 img",function(){
		location.href=URL_PROFILE+$(this).data('uid');
	});
	historyBack = function() {
		location.href='dongxibridge://js_navigation_pop';
	};
	setTitle = function(a) {
		location.href = 'dongxibridge://js_navigation_set_title?topic='+a;
	};
	userNeedLogin = function() {
		location.href = 'dongxibridge://js_user_need_login';
	};
});