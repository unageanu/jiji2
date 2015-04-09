'use strict';

var gulp      = require('gulp');
var del       = require('del');

gulp.task('clean', function(cb) {
    del([
      './build/apps/js',
      './build/apps/css',
      './build/spec/js'
    ], cb);
});
