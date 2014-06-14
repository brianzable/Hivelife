$(document).ready(function() {
	var isDragging = false;
	$('form').on('click', '.remove-fields', function(event) {
		$(this).prev('input[type=hidden]').val('1');
		$(this).closest('.dynamic').hide();
		event.preventDefault();
	});
	
	$('form').on('click', '.add-fields', function(event) {
		var time = new Date().getTime(),
							regexp = new RegExp($(this).data('id'), 'g');
		$(this).before($(this).data('fields').replace(regexp, time));
		event.preventDefault();
	});
	
	$(document).mousemove(function(event) {
		
		if (!isDragging)
			return;
			
		var source = event.target,
				box = $(source).closest('.radius');
		
		if (box.length == 0)
			return;
			
		setWidth(event);
	});
	
	$('form').on('click', '.radius', function(event) {
		setWidth(event);
	});
	
	$('form').on('mousedown', '.radius', function(event) {
		isDragging = true;
	});
	
	$('form').on('mouseup', document, function(event) {
		isDragging = false;
	});
});

function setWidth(event) {
	var box = $(event.target).closest('.percentage'),
			front = box.find('.radius').offset().left,
			end = front + box.width(),
			bar = $(box).find('.meter'),
			percentageLabel = $(box).find('.percentage-label'),
			percentage = parseInt(Math.ceil(((event.pageX - front) / box.width()) * 100)),
			input = $(box).find("input[type='hidden']");
	
	if (percentage > 100)
		percentage = 100;
	
	if (percentage < 0)
		percentage = 0;
	
	$(input).val(percentage);
	$(bar).css({width: percentage + '%'})
	$(percentageLabel).html(percentage + '%');
}