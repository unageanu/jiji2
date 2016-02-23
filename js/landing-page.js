$('#closing').on('inview', function(event, isInView) {
  if (isInView) {
    $('#bottom_install_button').removeClass("hide").addClass("animated fadeInUp");
  }
});
