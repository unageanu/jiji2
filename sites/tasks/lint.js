'use strict';

var gulp      = require('gulp');
var eslint    = require('gulp-eslint');

gulp.task('lint', function(cb) {
    return gulp.src(['src/js/**/*.js'])
        .pipe(eslint("./config/eslint.js"))
        .pipe(eslint.format());
});
