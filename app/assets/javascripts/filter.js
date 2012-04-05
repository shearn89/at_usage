$(function() {
	$('.hideme').hide();
	$("#submit_btn").hide();
	$("#machines th a").live("click", function() {
		$.getScript(this.href);
		return false;
	});
	$(".ajaxify a").live("click", function() {
		$.getScript(this.href);
		$('#entry').val('')
		return false;
	});
	$("#machines_search input").keyup(function() {
		$.get($("#machines_search").attr("action"), $("#machines_search").serialize(), null, "script");
		return false;
	});
});