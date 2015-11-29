# See webpack.config.js for more examples:
# https://github.com/webpack/webpack-with-common-libs/blob/master/webpack.config.js

path = require 'path'
webpack = require 'webpack'

# webpack-dev-server options used in gulpfile
# https://github.com/webpack/webpack-dev-server

module.exports =
  contentBase: "#{__dirname}/src/"
  cache: true

  entry:
    app:          './coffee/app'

  output:
    path: path.join(__dirname, 'src')
    publicPath: 'src/'
    filename: '[name].js'
    chunkFilename: '[chunkhash].js'

  module:
    loaders: [
      {
        test: /\.coffee$/
        loader: 'coffee-loader'
      }
      # {
      #   test: /\.scss$/,
      #   loader: "style-loader!sass-loader?outputStyle=expanded&includePaths[]=./bower_components/foundation/scss/"
      # }
      {
        # required to write 'require('./style.css')'
        test: /\.css$/
        loader: 'style-loader!css-loader'
      }
    ]

  resolve:
    extensions: ['', '.webpack.js', '.web.js', '.coffee', '.js', '.scss', '.css']
    modulesDirectories: ['src', 'coffee', 'styles', 'bower_components', 'node_modules']

  plugins: []
