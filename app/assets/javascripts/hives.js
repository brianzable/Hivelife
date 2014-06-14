$(document).ready(function() {
	setTimeout(function() {
    $('#tabs a').first().trigger('click');
  }, 100);

	$('#tabs a').click(function(event) {
		var source = event.target,
				toShow = $(source).data('show');

		$('#tabs a').each(function() {
			$(this).addClass('deselected');
		});

		$(this).removeClass('deselected');

		$('.content').each(function() {
			$(this).hide();
		});

		$('#' + toShow).show();
		event.preventDefault();
	});

	$(".location-tab").click(function() {
		$('.location-tab').each(function() {
			$(this).addClass('deselected');
		});
		$(this).removeClass('deselected');
	});

	$("#select-hive-location").click(function() {
		$("#hive-address-entry").hide();
		$("#hive-location-entry").show();
		google.maps.event.trigger(map, 'resize');
	});

	$("#select-hive-address").click(function() {
		$("#hive-location-entry").hide();
		$("#hive-address-entry").show();
	});

	$("#delete-hive").click(function() {
		event.preventDefault();
		var target = event.target,
				url = $(this).closest("form").attr("action");

		if (confirm("Are you sure you want delete this hive? \
								All data associated with this hive will be lost")) {
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
});
