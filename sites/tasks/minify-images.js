'use strict';

var gulp      = require('gulp');
var imageop   = require('gulp-image-optimization');

gulp.task('minify-images', ['build-less'], function () {
  var paths = (["gif","jpg","png"]).map(function(ext){
    return "./build/apps/images/**/*." + ext;
  });
  return gulp.src(paths)
      // .pipe(imageop({
      //     optimizationLevel: 5,
      //     progressive: true,
      //     interlaced: true
      // }))
      .pipe(gulp.dest("./build/minified/images"));
});
