'use strict';

var gulp      = require('gulp');
var minifyCSS = require('gulp-clean-css');

gulp.task('minify-css', ['build-less'], function () {
  return gulp.src("./build/apps/css/**/*.css")
      .pipe(minifyCSS({
        keepBreaks: true,
        keepSpecialComments: true,
        processImport: false
      }))
      .pipe(gulp.dest("./build/minified/css"));
});
