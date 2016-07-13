'use strict';

var gulp    = require('gulp');

gulp.task('build-debug', ['copy-font-resources', 'build-less', 'build-debug-js']);
gulp.task('build-release', ['copy-font-resources', 'build-less', 'build-release-js']);
