var gulp = require('gulp');
var plugins = require('gulp-load-plugins')();
var runSequence = require('run-sequence');

gulp.task('coffee', function() {
  gulp.src('assets/*.coffee')
    .pipe(plugins.coffee({bare: true}).on('error', gutil.log))
    .pipe(gulp.dest('./assets/js/'))
});

gulp.task('scripts', function() {
  gulp.src('assets/coffee/index.coffee', { read: false }) //paths.scripts
    .pipe(plugins.browserify({
      extensions: ['.coffee', '.hbs']
    }).on('error', plugins.util.log))
    .pipe(plugins.concat('app.js'))
    .pipe(gulp.dest('./assets/js/'));
});

gulp.task('styles', function() {
  gulp.src('assets/scss/**/*.scss')
    .pipe(plugins.sass().on('error', plugins.sass.logError))
    .pipe(gulp.dest('./assets/css/'));
});

gulp.task('watch_styles', function() {
  gulp.watch('assets/scss/**/*.scss',['styles']);
});

gulp.task('watch_scripts', function() {
  gulp.watch(['assets/coffee/**/*.coffee', 'assets/tmpl/**/*.hbs'], ['scripts']);
});

//Watch task
gulp.task('default',function() {
  runSequence(['watch_styles', 'watch_scripts']);
});
