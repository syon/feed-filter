$(function(){

  $('[data-toggle="tooltip"]').tooltip();

  $(document).on('click', '.rff-view :submit', function(e){
    e.preventDefault();
    var feedId = $('.rff-view [name="feed_id"]').val();
    if (!feedId.match(/[0-9]{10}/)) {
      return false;
    }
    document.location = "/view/" + feedId;
  });

  $(document).on('click', '.btn-inp-add', function(e){
    e.preventDefault();
    var $inp = $(this).closest('.form-group').find('input').first().clone();
    $inp.val("");
    $(this).before($inp);
    $inp.focus();
  });

  $(document).on('click', '#preview', function(e){
    e.preventDefault();
    $.ajax({
      url: "/preview",
      dataType:'json',
      data: {
        "feed_url": $('[name="feed_url"]').val(),
        "mute.title[]": _.map($('[name="mute.title[]"]'),function(d){return(d.value);}),
        "mute.domain[]": _.map($('[name="mute.domain[]"]'),function(d){return(d.value);})
      }
    }).done(function(data){
      var titles = data;
      $('#trial-result').empty();
      $.each(titles, function(i,title){
        var $li = $('<li>'+title+'</li>');
        if (title.match(/^\(Filtered\)/)) {
          $li.addClass('filtered');
        }
        $('#trial-result').append($li);
      });
    }).fail(function(data){
      console.log(data);
    });
  });

  $(document).on('click', '#delete', function(e){
    e.preventDefault();
    var feedId = $('form[name="rffedit"]').data('feedid');
    var form = document.rffedit;
    form.action = "/delete/" + feedId;
    if (confirm("削除します。よろしいですか？")) {
      form.submit();
    }
  });

});
