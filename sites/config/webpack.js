"use strict";

var webpack = require("webpack");
var merge   = require('deepmerge')

var base = {
  resolve: {
    alias: {
      msgpack:           __dirname + '/../lib/msgpack.codec.js',
      "react-draggable": __dirname + '/../lib/draggable.js',
      easeljs:           __dirname + '/../lib/easeljs-0.8.0.combined.js'
    }
  },
  plugins:  [
    new webpack.IgnorePlugin(/vertx/),
    new webpack.ProvidePlugin({
      createjs: "easeljs"
    })
  ],
  module: {
    loaders: [{
      test:     /\.js$/,
      exclude:  /(node_modules|lib)/,
      loader:  'babel-loader'
    }],

    exprContextRecursive : true,
    exprContextRegExp: /^\.\/(?!main)([a-zA-Z0-9\-\_\/]*)$/,
    exprContextCritical: false,
    exprContextRequest: '../../../src/js',

    unknownContextRegExp: /$^/,
    unknownContextCritical: false
  }
};

function createConfig( root, mainFile, options) {
  return merge( merge( base, {
    entry: '.' + root + '/' + mainFile,
    output: {
      filename: mainFile
    },
    resolve: {
      root: __dirname + root
    }
  }), options || {});
}

module.exports = {
  src : createConfig( '/src/js', 'main.js'),
  spec: createConfig( '/spec',   'all-specs.js', {
    resolve: {
      alias: {
        src:     __dirname + '/../src/js'
      }
    }
  })
}
