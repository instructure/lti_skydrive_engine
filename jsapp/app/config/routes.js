/** @jsx React.DOM */
var Router = require('react-router');
var Routes = Router.Routes;
var Route = Router.Route;

module.exports = (
  <Routes location="history">
    <Route handler={require('../components/app')}>
      <Route name="launch" path="/launch/:code" handler={require('../components/launch')} />
      <Route name="files" path="/files/:guid" handler={require('../components/files')} />
    </Route>
  </Routes>
);

