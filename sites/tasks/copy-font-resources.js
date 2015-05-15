'use strict';

var gulp = require('gulp');

gulp.task('copy-font-resources', function () {
  return gulp.src([
        'lib/material-design-iconic-font/fonts/**/*.*'
    ], {
      base: 'lib/material-design-iconic-font/fonts/'
    }).pipe(gulp.dest('build/apps/fonts'))
    .pipe(gulp.dest('build/minified/fonts'));
});
