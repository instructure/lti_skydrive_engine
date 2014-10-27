var _ = require('lodash')
  , axios = require('axios')
  , createStore = require('./createStore')
  , Q = require('q');

var OneDriveStore = createStore({
  accessToken: null,
  user: null,
  isAuthenticating: false,
  defaultDisplayName: 'None',
  rootUrl: null,
  launchParams: null,
  uri: null,
  authRedirectUrl: null,
  status: ''
});

OneDriveStore.setup = function(rootUrl, launchParams) {
  this.setState({
    rootUrl: rootUrl,
    launchParams: launchParams
  });
};

// Determine if the user is currently authenticated.
OneDriveStore.isAuthenticated = function() {
  return !_.isEmpty(this.getState().accessToken);
};

// display name helper
OneDriveStore.currentDisplayName = function() {
  if (this.getState().user) {
    return this.getState().user.name || this.getState().defaultDisplayName;
  } else {
    return this.getState().defaultDisplayName;
  }
};

OneDriveStore.authenticateWithCode = function(code) {
  var deferred = Q.defer();

  this.setState({ isAuthenticating: true, status: 'Authenticating...' });

  var success = function(response) {
    var apiKey = response.data.api_key;
    if (!_.isEmpty(apiKey)) {
      var user = this.authenticate(response.data.api_key.access_token);
      this.setState({ isAuthenticating: false, status: 'Authenticated!' });
      deferred.resolve(user);
    } else {
      deferred.reject(new Error('API Key missing'));
    }
  };

  var error = function(response) {
    this.setState({ isAuthenticating: false });
    deferred.reject(response.data);
  };

  axios.post(this.getState().rootUrl + 'oauth2/token', {code: code})
    .then(success.bind(this))
    .catch(error.bind(this));

  return deferred.promise;
};

// Log in the user
OneDriveStore.authenticate = function(token) {
  this.setState({ accessToken: token });
  this.fetchUser();
};

// Log out the user
OneDriveStore.reset = function(response) {
  debugger;
  this.setState({
    accessToken: null,
    user: null
  });
};

OneDriveStore.setUser = function(response) {
  this.setState({
    status: 'Loaded user data',
    user: response.data
  });
  return this.getState().user;
};

OneDriveStore.fetchUser = function() {
  this.setState({ status: 'Fetching user data...'});
  axios({
    url: this.getState().rootUrl + 'api/v1/users/self',
    headers: this.authHeaders()
  }).then(this.setUser.bind(this))
    .catch(this.reset.bind(this));
};

OneDriveStore.authorizeOneDrive = function() {
  this.setState({ status: 'Authorizing...'});
  var deferred = Q.defer();

  axios({
    url: this.getState().rootUrl + 'api/v1/skydrive_authorized',
    headers: this.authHeaders()
  }).then(
    axios({
      url: this.getState().rootUrl + 'api/v1/files/' + (this.getState().uri || 'root'),
      headers: this.authHeaders()
    }).then(function(response) {
      this.setState({
        data: response.data,
        isLoading: false,
        authRedirectUrl: null,
        status: 'Authorized!'
      });
      deferred.resolve(response.data);
    }.bind(this)).catch(function(response) {
      this.setState({
        isLoading: false,
        authRedirectUrl: response.data,
        status: 'Unable to authorize'
      });
      deferred.reject(response.data);
    }.bind(this))
  );

  return deferred.promise;
};

OneDriveStore.authHeaders = function() {
  return { 'Authorization': 'Bearer ' + (this.getState().accessToken || 'none') };
};

module.exports = OneDriveStore;