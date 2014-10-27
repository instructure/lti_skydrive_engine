module.exports = {
  entry: "./app/main.js",
  output: {
    filename: "public/bundle.js"
  },
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
};
