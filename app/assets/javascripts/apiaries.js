$(document).ready(function() {
	var apiary = $('#apiary').val();
	$('#settings-link').hide();

	$('#form-submit').click(function() {
		console.log($('#apiary-form'));
		$('#apiary-form').submit();
	});

  $('#display-photo, #settings-link').mouseenter(function() {
    $('#settings-link').toggle();
  }).mouseleave(function () {
    $('#settings-link').hide();
  });

	$('#add-beekeeper').click(function(event) {
		event.preventDefault();
		$("#beekeeper-errors").html("");
		var form = $("#beekeeper"),
				valuesToSubmit = $("#beekeeper").serialize();

		$.ajax({
      url: form.attr('action'),
  	  data: valuesToSubmit,
      method: "POST",
      dataType: "JSON",
      success: function(data){
      	$("#beekeeper-list").append(data.html);
    	},
    	error: function(xhr) {
    		console.log(xhr.responseText);
    		var errors = $.parseJSON(xhr.responseText).errors;
    		$("#beekeeper-errors").html(errors);
    	}
    });

		return false;
	});

	$("#delete-apiary").click(function() {
		event.preventDefault();
		var target = event.target,
				url = $(this).closest("form").attr("action");

		if (confirm("Are you sure you want delete this apiary? \
								All data associated with this apiary will be lost")) {
			$.ajax({
				url: url,
				type: 'POST',
				dataType: "JSON",
				data: { "_method":"delete" },
				success: function(data) {
					window.location.replace(url);
				}
			});
		}
	});

	$(document).on("click", ".delete-beekeeper", function(event) {
		event.preventDefault();
		var target = event.target,
				beekeeper = $(target).closest(".beekeeper"),
				url = beekeeper.data("path"),
				name = beekeeper.find("h6").html();

		if (confirm("Are you sure you want remove " + name + " from this apiary?")) {
			console.log();
			$.ajax({
				url: url,
				type: 'POST',
				dataType: "JSON",
				data: {
					"_method" : "delete",
					"beekeeper[apiary_id]" : apiary
				},
				success: function(result) {
					$(target).closest(".beekeeper").remove();
				}
			});
		}
	});

	$(document).on("change", ".permission", function(event) {
		var source = event.target,
				original = $(source).data("original"),
				beekeeper = $(source).closest(".beekeeper"),
				editUrl = beekeeper.data("path"),
				name = beekeeper.find("h6").html(),
				value = source.value,
				apiary = $("#apiary").val(),
				answer = true;

		if (original == "Admin") {
			if (!confirm("Are you sure you want to remove admin rights from " + name + "?")) {
				$(source).val(original);
				return;
			}
		}

		if (value == "Admin") {
			answer = confirm("Are you sure you want to make " + name + " an admin?");
		}

		if (answer) {
			$.ajax({
				url: editUrl,
				type: 'POST',
				dataType: "JSON",
				data: {
					"_method" : "PUT",
					"beekeeper[permission]": value,
					"beekeeper[apiary_id]" : apiary
				},
				error: function(result) {
					$(source).val(original);
				}
			});
		}
		else {
			$(source).val(original);
		}
	});
});
