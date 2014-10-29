var server = require('pushstate-server');

server.start({
  port: process.env.PORT || 8000,
  directory: './public'
});
