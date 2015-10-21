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
    var feedUrl = $('[name="feed_url"]').val();
    var titles = _.map($('[name="mute.title[]"]'),function(d){return(d.value);});
    var domains = _.map($('[name="mute.domain[]"]'),function(d){return(d.value);});
    var urlPrefix = _.map($('[name="mute.url_prefix[]"]'),function(d){return(d.value);});
    preview(feedUrl, titles, domains, urlPrefix);
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

function preview(feedUrl, titles, domains, urlPrefix) {
  $('#preview').prop('disabled', true);
  $('.fa-spin').show();
  $.ajax({
    type: 'POST',
    url: "/preview",
    dataType:'json',
    data: {
      "feed_url": feedUrl,
      "mute.title[]": titles,
      "mute.domain[]": domains,
      "mute.url_prefix[]": urlPrefix
    }
  }).done(function(data){
    $('#preview-result').empty();

    $.each(data, function(i,item){
      var $li = $('<li>'+item.title+'</li>');
      if (item.title.match(/^\(Filtered\)/)) {
        $li.addClass('filtered');
      }
      $('#preview-result').append($li);
    });

    $('#preview').prop('disabled', false);
    $('.fa-spin').hide();

  }).fail(function(data){
    $('#preview').prop('disabled', false);
    $('.fa-spin').hide();
    console.error("Preview is failed.");
    console.log(data);
  });
}
