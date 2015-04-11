'use strict';

var gulp    = require('gulp');

gulp.task('watch', ['lint', 'build'], function(){
  gulp.watch('./src/less/**/*.less', ['build-less']);
  gulp.watch('./src/js/**/*.js',     ['lint', 'build-js']);
  gulp.watch('./spec/**/*.js',       ['lint', 'build-spec']);
});
