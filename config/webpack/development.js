process.env.NODE_ENV = process.env.NODE_ENV || 'development'

<<<<<<< HEAD
const { merge } = require('@rails/webpacker')
const webpackConfig = require('./base');
const ESLintPlugin = require('eslint-webpack-plugin');

module.exports = merge(webpackConfig, {
  plugins: [
    new ESLintPlugin({
      cache: true,
      threads: true,
      emitWarning: true
    })
  ]
});
=======
const environment = require('./environment')

module.exports = environment.toWebpackConfig()
>>>>>>> 32f252673... Init config
