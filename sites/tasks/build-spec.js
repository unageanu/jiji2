'use strict';

var gulp    = require('gulp');
var webpack = require('webpack-stream');
var configBuilder = require('../config/webpack.js');

gulp.task('build-spec', ['prepare-build'], function () {
  var config = configBuilder.spec("development");
  return gulp.src(config.entry)
      .pipe(webpack(config))
      .pipe(gulp.dest("./build/spec/js"));
});
