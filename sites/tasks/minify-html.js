'use strict';

var gulp       = require('gulp');
var minifyHTML = require('gulp-minify-html');

gulp.task('minify-html', function () {
    return gulp.src("./build/apps/html/**/*.html")
        .pipe(minifyHTML({
          conditionals: true
        }))
        .pipe(gulp.dest("./build/minified/html"));
});
