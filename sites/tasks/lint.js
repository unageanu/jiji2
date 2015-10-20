'use strict';

var gulp      = require('gulp');
var eslint    = require('gulp-eslint');

gulp.task('lint', function(cb) {
  return gulp.src(['src/js/**/*.js','spec/**/*.js'])
      .pipe(eslint("./config/eslint.json"))
      .pipe(eslint.format());
});
