module.exports = function(config) {
  config.set({

    basePath: '',

    frameworks: ['mocha'],

    files: [
      // need to figure out how to get webpack to take a glob w/o duplicating
      // stuff everywhere
      'node_modules/sinon/pkg/sinon.js',
      'node_modules/jquery/dist/jquery.js',
      'node_modules/jquery.cookie/jquery.cookie.js',
      'app/__tests__/main.js'
    ],

    exclude: [],

    preprocessors: {
      'app/__tests__/main.js': ['webpack']
    },

    webpack: {
      cache: true,
      module: {
        loaders: [
          { test: /\.less$/,   loader: 'style-loader!css-loader!less-loader' },
          { test: /\.js$/,     loader: 'jsx-loader' },
          { test: /\.woff$/,   loader: 'url-loader?limit=10000&minetype=application/font-woff' },
          { test: /\.ttf$/,    loader: 'file-loader' },
          { test: /\.eot$/,    loader: 'file-loader' },
          { test: /\.svg$/,    loader: 'file-loader' },
          { test: /\.png$/,    loader: "url-loader?mimetype=image/png" }
        ]
      }
    },

    webpackServer: {
      stats: {
        colors: true
      }
    },

    reporters: ['mocha'],

    // reporter options
    mochaReporter: {
      output: 'autowatch'
    },

    port: 9876,

    colors: true,

    logLevel: config.LOG_INFO,

    autoWatch: true,

    browsers: ['Chrome'],

    captureTimeout: 60000,

    singleRun: false,

    plugins: [
      require("karma-mocha"),
      require("karma-chrome-launcher"),
      require("karma-firefox-launcher"),
      require("karma-webpack"),
      require("karma-mocha-reporter")
    ]
  });
};

