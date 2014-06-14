$('#fileupload').fileupload({
  add: function(e, data) {
    var types = /(\.|\/)(gif|jpe?g|png)$/i,
        file = data.files[0];
    if (types.test(file.type) || types.test(file.name)) {
      $('#upload-progress').show();
      data.submit();
    }
    else
      alert(file.name + ' is not a gif, jpeg, or png image file');
  },
  progress: function(e, data) {
    progress = parseInt(data.loaded / data.total * 100, 10);
    $('#upload-progress .meter').width(progress + '%');
  },
  done: function(e, data) {
    var to = $('#fileupload').data('post'),
        as = $('#fileupload').data('as'),
        bucket = $('#fileupload').attr('action'),
        file = data.files[0],
        path = $('#fileupload input[name=key]').val().replace('${filename}', file.name);
    $('#preview-image').attr('src', bucket + path);
    $('#display-photo').attr('src', bucket + path);
    $('#photo_url').val(path);
    $('#upload-progress').hide();

    var postData = {};
    postData[as] = path;
    postData['_method'] = 'PUT';

    $.ajax({
      url: to,
      type: 'POST',
      dataType: 'JSON',
      data: postData,
      error: function(result) {
        console.log(result)
      }
    });
    //$('#upload-modal').foundation('reveal', 'close');
  },
  fail: function(e, data) {
    alert(data.files[0].name + ' failed to upload.');
    $('#upload-progress').hide();
    console.log('Upload failed:');
    console.log(data);
  }
});

$(document).ready(function() {
  $('#upload-photo').click(function(event) {
    event.preventDefault();
    $('#upload-field').trigger('click');
  });
});
