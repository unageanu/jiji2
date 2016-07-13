'use strict';

var gulp          = require('gulp');
var webpack       = require('gulp-webpack');
var configBuilder = require('../config/webpack.js');

function build(env) {
  var config = configBuilder.src(env);
  return gulp.src(config.entry)
      .pipe(webpack(config))
      .pipe(gulp.dest("./build/apps/js"));
}

gulp.task('build-debug-js', ['prepare-build'], function () {
    return build("development");
});

gulp.task('build-release-js', ['prepare-build'], function () {
  return build("production");
});
