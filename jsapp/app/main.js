var React = window.React = require('react');
var routes = require('./config/routes');

var store = require('./lib/OneDriveStore');
store.setup(window.ROOT_URL, window.LAUNCH_PARAMS);
window.store = store;

require('./css/main.less');

React.renderComponent(routes, document.body);

