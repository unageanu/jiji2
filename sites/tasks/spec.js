'use strict';

var gulp    = require('gulp');
var jasmine = require('gulp-jasmine');

gulp.task('spec', ['build-spec'], function(done) {
  return gulp.src('build/spec/js/all-specs.js')
      .pipe(jasmine());
});
