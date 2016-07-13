'use strict';

var gulp    = require('gulp');
var webpack = require('gulp-webpack');
var configBuilder = require('../config/webpack.js');

gulp.task('build-spec', ['prepare-build'], function () {
  const config = configBuilder.src("development");
  return gulp.src(config.entry)
      .pipe(webpack(config))
      .pipe(gulp.dest("./build/spec/js"));
});
