"use strict";

var webpack = require("webpack");
var merge   = require('deepmerge')

var base = {
  resolve: {
    alias: {
      msgpack:           __dirname + '/../lib/msgpack.codec.js',
      easeljs:           __dirname + '/../lib/easeljs-0.8.0.combined.js',
      ga:                __dirname + '/../lib/ga.js'
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
      loader:  'babel-loader',
      query: {
        presets: ['es2015', 'react', 'stage-0'],
        cacheDirectory: "cache/babel-cache"
      }
    }, {
      test:     /\.jsx/,
      loader: 'jsx'
    }],

    exprContextRecursive : true,
    exprContextRegExp: /^\.\/(?!main)([a-zA-Z0-9\-\_\/]*)$/,
    exprContextCritical: false,
    exprContextRequest: __dirname + '/../src/js',

    unknownContextRegExp: /$^/,
    unknownContextCritical: false
  }
};

function createConfig( root, mainFile, env, options) {
  const config = merge( merge( base, {
    entry: '.' + root + '/' + mainFile,
    output: {
      filename: mainFile
    },
    resolve: {
      root: __dirname + root
    }
  }), options || {});
  config.plugins.push(new webpack.DefinePlugin({
    'process.env':{
      'NODE_ENV': JSON.stringify(env)
    }
  }));
  return config;
}

module.exports = {
  src : function(env) {
    return createConfig( '/src/js', 'main.js', env );
  },
  spec: function(env) {
    return createConfig( '/spec', 'all-specs.js', env, {
      resolve: {
        alias: {
          src:     __dirname + '/../src/js'
        }
      }
    });
  }
}
