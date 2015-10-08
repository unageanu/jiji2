'use strict';

var gulp    = require('gulp');
var mkdir   = require('mkdir-p');

gulp.task('prepare-build', function (cb) {
  mkdir('cache/babel-cache', cb);
});
