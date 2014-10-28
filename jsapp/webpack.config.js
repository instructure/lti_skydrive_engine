module.exports = {
  entry: "./app/main.js",
  output: {
    path: __dirname + "/public",
    filename: "bundle.js"
  },
  module: {
    loaders: [
      { test: /\.less$/,   loader: 'style-loader!css-loader!less-loader' },
      { test: /\.js$/,     loader: 'jsx-loader' },
      { test: /\.png$/,    loader: "url-loader?mimetype=image/png" },
      { test: /\.woff(\?v=[0-9]\.[0-9]\.[0-9])?$/, loader: "url-loader?limit=10000&minetype=application/font-woff" },
      { test: /\.(ttf|eot|svg)(\?v=[0-9]\.[0-9]\.[0-9])?$/, loader: "file-loader" }
    ]
  }
};
