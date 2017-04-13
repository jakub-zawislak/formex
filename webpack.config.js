var webpack = require('webpack')

module.exports = {
  entry: {
    formex: [
      "./web/static/js/formex.js"
    ],
  },
  output: {
    path: __dirname+"/priv/static/js",
    filename: "[name].js",
    library: 'webpackNumbers',
    libraryTarget: 'umd'
  },

  module: {
    rules: [{
      test: /\.js$/,
      exclude: /node_modules/,
      loader: "babel-loader",
      options: {
        presets: [
          ["es2015", { modules: false }]
        ]
      }
    }]
  },

  resolve: {
    modules: [ "node_modules", __dirname + "/web/static/js" ] // eslint-disable-line no-undef
  },

  plugins: [
  ]
}
