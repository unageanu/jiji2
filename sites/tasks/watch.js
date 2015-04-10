'use strict';

var gulp    = require('gulp');

gulp.task('watch', function(){
  gulp.watch('./src/less/**/*.less', ['build-less']);
  gulp.watch('./src/js/**/*.js',     ['build-js']);
  gulp.watch('./spec/**/*.js',       ['build-spec']);
});
