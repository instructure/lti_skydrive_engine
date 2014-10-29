/** @jsx React.DOM */
var Router = require('react-router')
  , Routes = Router.Routes
  , Route = Router.Route
  , Redirect = Router.Redirect
  , NotFoundRoute = Router.NotFoundRoute
  , App = require('../components/App')
  , Index = require('../components/Index')
  , Launch = require('../components/Launch')
  , Files = require('../components/Files')
  , Login = require('../components/Login')
  , AuthFailed = require('../components/AuthFailed')
  , OauthCallback = require('../components/OauthCallback');

module.exports = (
  <Routes location="history">
    <Route handler={App}>
      <Route name="index" path="/skydrive/?" handler={Index} />
      <Route name="launch" path="/skydrive/launch/:code" handler={Launch} />
      <Route name="files" path="/skydrive/files" handler={Files} />
      <Route name="login" path="/skydrive/login" handler={Login} />
      <Route name="oauth-callback" path="/skydrive/oauth/callback" handler={OauthCallback} />
      <Route name="auth-failed" path="/skydrive/auth-failed" handler={AuthFailed} />
    </Route>
    <Redirect path="/" to="index" />
    <NotFoundRoute handler={AuthFailed}/>
  </Routes>
);

