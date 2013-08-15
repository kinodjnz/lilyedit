$(document).ready(function(){
	var anim_time = 200;
	$(".alert").alert();
	var handle_button = function(h) {
		$("#error").hide();
		$("#message").hide();
		$(h.button).button("loading");
		$.ajax({
			type: "POST",
			url: h.post_url,
			data: editor.getValue(),
			dataType: "json",
			error: function(req, status, thrown) {
				$("#error-text").text("通信エラー: " + status + " " + thrown);
				$("#error").show();
				if (h.error) {
					h.error();
				}
				$(h.button).button("reset");
			},
			success: function(data, dataType) {
				if (data.result == "true") {
					if (h.success) {
						h.success(data);
					}
				} else {
					$("#error-text").text(h.compose_failure_text(data));
					$("#error").show();
					if (h.failure) {
						h.failure(data);
					}
				}
				$(h.button).button("reset");
			}
		});
	}
	$("#create_button").click(function() {
		handle_button({
			post_url: "/create",
			success: function(data) {
				location.href = data.url;
			},
			compose_failure_message: function(data) {
				return "作成に失敗しました: " + data.message;
			}
		});
	});
	$("#save_button").click(function() {
		handle_button({
			post_url: "/save/" + fileid,
			success: function(data) {
				$("#message-text").text("保存しました");
				$("#message").show();
			},
			compose_failure_message: function(data) {
				return "保存に失敗しました: " + data.message;
			}
		});
	});
	$("#compile_button").click(function() {
		$("#output_link").hide();
		$("#response-text").val("");
		handle_button({
			post_url: "/compile/" + fileid,
			button: "#compile_button",
			success: function(data) {
				$("#response-text").val(data.response);
				$("#response").show();
				$("#output_link").attr("href", data.url);
				$("#output_link").show();
			},
			failure: function(data) {
				$("#response-text").val(data.response);
				$("#response").show();
			},
			compose_failure_message: function(data) {
				return "コンパイルに失敗しました: " + data.message;
			}
		});
	});
	$("#collapse-response").click(function() {
		$("#response").toggle(anim_time);
	});
    var editor = ace.edit("editor");
    editor.setTheme("ace/theme/clouds");
    // editor.getSession().setMode("ace/mode/javascript");
});
