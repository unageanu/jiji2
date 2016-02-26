// $('#first-hook').on('inview', function(event, isInView) {
//   if (isInView) {
//     $('#site-header').removeClass("fixed animated fadeInDown");
//   } else {
//     $('#site-header').addClass('fixed animated fadeInDown');
//   }
// });

$('#closing').on('inview', function(event, isInView) {
  if (isInView) {
    $('#bottom_install_button').removeClass("hide").addClass("animated fadeInUp");
  }
});
