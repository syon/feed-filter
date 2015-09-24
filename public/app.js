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

});
