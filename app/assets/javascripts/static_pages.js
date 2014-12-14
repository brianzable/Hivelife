$(document).ready(function() {
  $('#signup-button').click(function (e) {
    e.stopPropagation();
    e.preventDefault();

    var input = $('#input').val();

    if (input == '') {
      return;
    }

    $.ajax({
      type: 'POST',
      url: '/mailing_list',
      dataType: 'application/json',
      data: { landing_page_signup: { email_address: input }},
      complete: function(response) {
        if (response.status == 200) {
          $('#result-message').html("Thanks for the support!");
        }
        else {
          $('#result-message').html("Something went wrong! Please try again later");
        }
      }
    });
  });
});
