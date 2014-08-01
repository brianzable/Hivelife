$(document).ready(function() {
	$('#settings-link').hide();

	var beekeepers = new Array();

	$(document).on('click', '.remove-beekeeper', function(event) {
		event.preventDefault();
		var beekeeper = $(this).closest('.beekeeper'),
				emailAddress = $(beekeeper).find('.beekeeper-email').val();
		beekeepers = $.grep(beekeepers, function(value) {
			return value != emailAddress;
		});
		console.log(beekeepers);
	});

	$('.beekeeper').each(function() {
		beekeepers.push($(this).find('.beekeeper-email').val());
	});

  $('#display-photo, #settings-link').mouseenter(function() {
    $('#settings-link').toggle();
  }).mouseleave(function () {
    $('#settings-link').hide();
  });

	$('#add-beekeeper').click(function(event) {
		event.preventDefault();
		$('#beekeeper-error').html('');

		var emailAddress = $('#beekeeper-email').val(),
				apiaryId 		 = $('#apiary-id').val();

		if ($.inArray(emailAddress, beekeepers) > -1) {
			return;
		}

		var time = new Date().getTime(),
							regexp = new RegExp($(this).data('id'), 'g');

		var wrapper = document.createElement('div');
		wrapper.innerHTML = $(this).data('fields').replace(regexp, time);

		var data = {
			beekeeper: {
				email: emailAddress,
				permission: 'Read'
			}
		};

		$.ajax({
			url: '/apiaries/' + apiaryId + '/beekeepers/new/preview',
			data: data,
			method: 'POST',
			dataType: 'JSON',
			success: function(data) {
				var user = data.user;
				$(wrapper).find('.beekeeper-name').html(user.first_name + ' ' + user.last_name);
				$(wrapper).find('.beekeeper-email').val(emailAddress);
				$('#beekeeper-list').append(wrapper.innerHTML);
				beekeepers.push(emailAddress);
			},
			error: function(xhr) {
				var errors = JSON.parse(xhr.responseText).errors;
				$('#beekeeper-error').html(errors.join(', '));
			}
		});

		return false;
	});
});
