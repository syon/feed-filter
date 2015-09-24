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
  });

});
