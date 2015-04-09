'use strict';

var gulp    = require('gulp');
var uglify  = require('gulp-uglify');
var webpack = require('gulp-webpack');
var config  = require('../config/webpack.js').spec;

gulp.task('build-spec', function () {
    return gulp.src(config.entry)
        .pipe(webpack(config))
        .pipe(uglify())
        .pipe(gulp.dest("./build/spec/js"));
});
