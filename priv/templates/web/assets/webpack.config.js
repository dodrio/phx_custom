/* eslint-env node */

const path = require('path')
const glob = require('glob')
const sass = require('sass')
const cssnano = require('cssnano')
const autoprefixer = require('autoprefixer')
const MiniCSSExtractPlugin = require('mini-css-extract-plugin')
const UglifyJsPlugin = require('uglifyjs-webpack-plugin')
const OptimizeCSSAssetsPlugin = require('optimize-css-assets-webpack-plugin')
const CopyWebpackPlugin = require('copy-webpack-plugin')

function resolveSrc(relativePath = '') {
  const root = path.resolve(__dirname)
  const absolutePath = path.join(root, relativePath)

  return absolutePath
}

const srcStatic = resolveSrc('static/')

function resolvePublic(relativePath = '') {
  const root = path.resolve(__dirname, '../priv/static')
  const absolutePath = path.join(root, relativePath)

  return absolutePath
}

const publicRoot = resolvePublic('./')
const publicJS = resolvePublic('js/')
const publicCSS = resolvePublic('css/')
const publicFonts = resolvePublic('fonts/')

module.exports = env => ({
  optimization: {
    minimizer: [
      new UglifyJsPlugin({ cache: true, parallel: true, sourceMap: false }),
      new OptimizeCSSAssetsPlugin({
        cssProcessor: cssnano,
        cssProcessorPluginOptions: {
          preset: ['default', { discardComments: { removeAll: true } }],
        },
      }),
    ],
  },
  devtool:
    env === 'production'
      ? 'nosources-source-map'
      : 'cheap-module-eval-source-map',
  resolve: {
    extensions: ['.js', '.scss', '.css'],
  },
  entry: {
    app: [resolveSrc('app/index.js')].concat(
      glob.sync(resolveSrc('app/vendor/**/*.js'))
    ),
    admin: [resolveSrc('admin/index.js')].concat(
      glob.sync(resolveSrc('admin/vendor/**/*.js'))
    ),
  },
  output: {
    filename: '[name].js',
    path: publicJS,
  },
  plugins: [
    // path of filename is relative to priv/static/js
    new MiniCSSExtractPlugin({
      // filename must be a relative path, crap!
      filename: path.relative(publicJS, publicCSS) + '/[name].css',
    }),
    new CopyWebpackPlugin([{ from: srcStatic, to: publicRoot }]),
  ],
  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        use: {
          loader: 'babel-loader',
        },
      },
      {
        test: /\.css$/,
        use: [MiniCSSExtractPlugin.loader, 'css-loader'],
      },
      {
        test: /\.scss|\.sass$/,
        use: [
          MiniCSSExtractPlugin.loader,
          'css-loader',
          {
            loader: 'postcss-loader',
            options: {
              plugins: [autoprefixer()],
            },
          },
          {
            loader: 'sass-loader',
            options: {
              implementation: sass,
              sourceMap: true,
              sourceMapContents: false,
            },
          },
        ],
      },
      {
        test: /\.(eot|woff|woff2|ttf|svg)$/,
        use: [
          {
            loader: 'file-loader',
            options: {
              name: '[name].[ext]',
              outputPath: path.relative(publicJS, publicFonts),
              publicPath: '/fonts',
            },
          },
        ],
      },
    ],
  },
})
