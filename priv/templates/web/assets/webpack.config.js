/* eslint-env node */
const path = require('path')
const glob = require('glob')

// Webpack
const merge = require('webpack-merge')
const MiniCSSExtractPlugin = require('mini-css-extract-plugin')
const TerserPlugin = require('terser-webpack-plugin')
const OptimizeCSSAssetsPlugin = require('optimize-css-assets-webpack-plugin')
const CopyWebpackPlugin = require('copy-webpack-plugin')

// PostCSS
const pcImport = require('postcss-import')
const pcNested = require('postcss-nested')
const pcAutoprefixer = require('autoprefixer')
const pcPurgecss = require('@fullhuman/postcss-purgecss')

// TailwindCSS
const tailwindcss = require('tailwindcss')

// Locations
const srcStatic = resolveSrc('static/')
const destRoot = resolveDest('./')
const destJS = resolveDest('js/')
const destCSS = resolveDest('css/')
const destFont = resolveDest('fonts/')
const destImage = resolveDest('images/')
const publicFont = path.join('/', path.relative(destRoot, destFont))
const publicImage = path.join('/', path.relative(destRoot, destImage))

function resolveSrc(relativePath = '') {
  const root = path.resolve(__dirname)
  const absPath = path.join(root, relativePath)
  return absPath
}

function resolveDest(relativePath = '') {
  const root = path.resolve(__dirname, '../priv/static')
  const absPath = path.join(root, relativePath)
  return absPath
}

// Webpack Configurations
module.exports = (_env, { mode }) => {
  const isProd = mode === 'production'

  return merge([
    loadJS(isProd),
    loadCSS(isProd),
    loadFont(),
    loadImage(),
    copyStatic(),
  ])
}

function loadJS(isProd) {
  return {
    resolve: {
      extensions: ['.js'],
    },
    entry: {
      app: [].concat(
        resolveSrc('index.js'),
        glob.sync(resolveSrc('vendor/**/*.js'))
      ),
    },
    output: {
      filename: '[name].js',
      path: destJS,
    },
    module: {
      rules: [
        {
          test: /\.js$/,
          exclude: /node_modules/,
          use: {
            loader: 'babel-loader',
          },
        },
      ],
    },
    devtool: isProd ? 'nosources-source-map' : 'source-map',
    optimization: {
      minimizer: [
        // sourceMap options only works with devtool options with following values:
        // + source-map
        // + inline-source-map
        // + hidden-source-map
        // + nosources-source-map
        new TerserPlugin({ cache: true, parallel: true, sourceMap: !isProd }),
      ],
    },
  }
}

function loadCSS(isProd) {
  let pcPlugins = [pcImport, tailwindcss, pcNested, pcAutoprefixer]
  if (isProd) {
    pcPlugins = pcPlugins.concat(
      pcPurgecss({
        content: [
          '../**/*.html.eex',
          '../**/*.html.leex',
          '../**/views/**/*.ex',
          '../**/live/**/*.ex',
          './**/*.js',
        ],
        defaultExtractor: content => content.match(/[\w-/:]+(?<!:)/g) || [],
      })
    )
  }

  return {
    resolve: {
      extensions: ['.css'],
    },
    module: {
      rules: [
        {
          test: /\.css$/,
          use: [
            {
              loader: MiniCSSExtractPlugin.loader,
            },
            {
              loader: 'css-loader',
              options: {
                sourceMap: true,
              },
            },
            {
              loader: 'postcss-loader',
              options: {
                ident: 'postcss',
                plugins: pcPlugins,
                sourceMap: true,
              },
            },
          ],
        },
      ],
    },
    plugins: [
      new MiniCSSExtractPlugin({
        // path of CSS filename is relative to destJS
        filename: path.join(path.relative(destJS, destCSS), '[name].css'),
      }),
    ],
    optimization: {
      minimizer: [new OptimizeCSSAssetsPlugin({})],
    },
  }
}

function loadFont() {
  return {
    module: {
      rules: [
        {
          test: /\.(eot|woff|woff2|ttf)$/,
          use: [
            {
              loader: 'file-loader',
              options: {
                name: '[name].[ext]',
                outputPath: path.relative(destJS, destFont),
                publicPath: publicFont,
              },
            },
          ],
        },
      ],
    },
  }
}

function loadImage() {
  return {
    module: {
      rules: [
        {
          test: /\.(png|jpe?g|gif|svg)$/,
          use: [
            {
              loader: 'file-loader',
              options: {
                name: '[name].[ext]',
                outputPath: path.relative(destJS, destImage),
                publicPath: publicImage,
              },
            },
          ],
        },
      ],
    },
  }
}

function copyStatic() {
  return {
    plugins: [
      new CopyWebpackPlugin({
        patterns: [{ from: srcStatic, to: destRoot }],
      }),
    ],
  }
}
