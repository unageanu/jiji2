'use strict';

var gulp    = require('gulp');

gulp.task('build', ['copy-font-resources', 'build-less', 'build-js']);
