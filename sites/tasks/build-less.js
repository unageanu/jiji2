var gulp         = require('gulp');
var less         = require('gulp-less');
var autoprefixer = require('gulp-autoprefixer');

gulp.task('build-less', function() {
  return gulp.src("./src/less/*.less")
    .pipe(less())
    .pipe(autoprefixer({cascade: false, browsers: ['last 2 versions']}))
    .pipe(gulp.dest('./build/apps/css'));
});
