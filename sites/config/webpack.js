"use strict";

var webpack = require("webpack");

var base = {
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

var alias = {
  src:     __dirname + '/../src/js',
  msgpack: __dirname + '/../lib/msgpack.codec.js'
};
var plugins =  [
    new webpack.IgnorePlugin(/vertx/)
];

module.exports = {
    src : {
        entry: './src/js/main.js',
        output: {
            filename: 'main.js'
        },
        resolve: {
            root: __dirname + '/src/js',
            alias: alias
        },
        module: base.module,
        plugins: plugins
    },

    spec: {
        entry: './spec/all-specs.js',
        output: {
            filename: 'all-specs.js'
        },
        resolve: {
            root: __dirname + '/spec',
            alias: alias
        },
        module: base.module,
        plugins: plugins
    }
}
