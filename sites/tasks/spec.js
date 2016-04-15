'use strict';

var gulp     = require('gulp');
var jasmine  = require('gulp-jasmine');
var istanbul = require('gulp-istanbul');

gulp.task('spec', /*['build-spec'],*/ function(done) {
  return gulp.src('build/spec/js/all-specs.js')
      .pipe(jasmine())
      .pipe(istanbul.writeReports({
        dir: "./coverage",
        reportOpts: {dir: "./coverage"},
        reporters: ['text', 'text-summary', 'json', 'html']
      }));
});
