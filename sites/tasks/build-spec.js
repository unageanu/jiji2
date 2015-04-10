'use strict';

var gulp    = require('gulp');
var webpack = require('gulp-webpack');
var config  = require('../config/webpack.js').spec;

gulp.task('build-spec', function () {
    return gulp.src(config.entry)
        .pipe(webpack(config))
        .pipe(gulp.dest("./build/spec/js"));
});
