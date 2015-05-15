'use strict';

var gulp    = require('gulp');

gulp.task('minify', [
  'copy-font-resources',
  'minify-js',  'minify-css',
  'minify-html','minify-images'
]);
