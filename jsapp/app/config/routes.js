/** @jsx React.DOM */
var Router = require('react-router');
var Routes = Router.Routes;
var Route = Router.Route;
var Redirect = Router.Redirect;

var App = require('../components/App');
var Index = require('../components/Index');
var Launch = require('../components/Launch');
var Files = require('../components/Files');
var Login = require('../components/Login');
var AuthFailed = require('../components/AuthFailed');

module.exports = (
  <Routes location="history">
    <Route handler={App}>
      <Route name="index" path="/skydrive/?" handler={Index} />
      <Route name="launch" path="/skydrive/launch/:code" handler={Launch} />
      <Route name="files" path="/skydrive/files/*" handler={Files} />
      <Route name="login" path="/skydrive/login" handler={Login} />
      <Route name="auth-failed" path="/skydrive/auth-failed" handler={AuthFailed} />
    </Route>
    <Redirect path="/" to="index" />
  </Routes>
);

