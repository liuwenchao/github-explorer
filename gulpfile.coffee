# See example gulpfile.js for file system development build:
# https://github.com/webpack/webpack-with-common-libs/blob/master/gulpfile.js

del               = require 'del'

gulp              = require 'gulp'
$                 = require('gulp-load-plugins')();

webpack           = require 'webpack'
WebpackDevServer  = require 'webpack-dev-server'
webpackConfig     = require './webpack.config.coffee'
vinylPaths        = require 'vinyl-paths'

# Default task
gulp.task 'default', ['webpack-dev-server'], ->


############################################################
# Development build
############################################################
gulp.task 'webpack-dev-server', (callback) ->
  # modify some webpack config options
  conf = Object.create webpackConfig
  conf.devtool = 'source-map'
  conf.debug = true

  # Start a webpack-dev-server
  new WebpackDevServer webpack(conf),
    contentBase: conf.contentBase
    stats:
      colors: true
  .listen 8000, 'localhost', (err) ->
    throw new $.util.PluginError('webpack-dev-server', err) if err
    $.util.log '[webpack-dev-server]', 'http://localhost:8000/webpack-dev-server/index.html'


############################################################
# Production build
############################################################
gulp.task 'clean', del.bind null, ['dist']

gulp.task 'build', ['webpack:build'], ->
  revAll = new $.revAll
    dontRenameFile: [
      /^\/favicon.ico$/g
      /^\/CNAME$/g
      /^\/index.html$/g
      /^\/app.html$/g
      /^\/callback.html$/g
      /^\/robots.txt$/g
    ]
  gulp.src 'src/**'
  .pipe $.if 'src/images/*'
  , $.changed 'dist/images'
  , $.cache $.imagemin
      progressive: true
      interlaced: true
  .pipe $.if '*.css'
  , $.csso()
  # , $.autoprefixer
  #   browsers: [
  #     'ie >= 10'
  #     'ie_mob >= 10'
  #     'ff >= 30'
  #     'chrome >= 34'
  #     'safari >= 7'
  #     'opera >= 23'
  #     'ios >= 7'
  #     'android >= 4.4'
  #     'bb >= 10'
  #   ]
  .pipe $.if '*.html', $.minifyHtml
    empty: true
    spare: true
    comments: true
  .pipe $.if '*.js', $.uglify()
  .pipe revAll.revision()
  .pipe gulp.dest 'dist'
  .pipe revAll.manifestFile()
  .pipe gulp.dest 'dist'
  .pipe revAll.versionFile()
  .pipe gulp.dest 'dist'

gulp.task 'webpack:build', (callback) ->
  conf = Object.create webpackConfig
  conf.plugins = conf.plugins.concat new webpack.DefinePlugin
    'process.env':
      NODE_ENV: JSON.stringify('production')
  , new webpack.optimize.DedupePlugin()
  , new webpack.optimize.UglifyJsPlugin()

  # run webpack
  webpack conf, (err, stats) ->
    throw new $.util.PluginError('webpack:build', err) if err
    $.util.log '[webpack:build]', stats.toString colors: true
    callback()

gulp.task 'deploy', ['build'], ->
  gulp.src 'dist'
    .pipe $.subtree()
    .pipe vinylPaths(del)
