'use strict';

var gulp    = require('gulp');
var uglify  = require('gulp-uglify');

gulp.task('minify-js', ['build-js'], function () {
  return gulp.src("./build/apps/js/**/*.js")
      .pipe(uglify())
      .pipe(gulp.dest("./build/minified/js"));
});
