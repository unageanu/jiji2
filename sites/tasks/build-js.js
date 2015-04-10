'use strict';

var gulp    = require('gulp');
var webpack = require('gulp-webpack');
var config  = require('../config/webpack.js').src;

gulp.task('build-js', function () {
    return gulp.src(config.entry)
        .pipe(webpack(config))
        .pipe(gulp.dest("./build/apps/js"));
});
