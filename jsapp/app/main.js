var React = window.React = require('react');
var routes = require('./config/routes');

Function.prototype.extractComment = function() {
  var startComment = '/*!',
      endComment = '*/',
      str = this.toString(),
      start = str.indexOf(startComment),
      end = str.lastIndexOf(endComment);

  return str.slice(start + startComment.length, -(str.length - end));
};

var store = require('./lib/OneDriveStore');
store.setup(window.ROOT_URL, window.MOUNT_PATH);
window.store = store;

require('./css/main.less');

React.renderComponent(routes, document.body);

