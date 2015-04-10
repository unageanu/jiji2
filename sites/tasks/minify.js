'use strict';

var gulp    = require('gulp');

gulp.task('minify', [
  'minify-js',  'minify-css',
  'minify-html','minify-images'
]);
