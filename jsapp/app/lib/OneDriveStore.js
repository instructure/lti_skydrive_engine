var $ = require('jquery')
  , _ = require('lodash')
  , axios = require('axios')
  , createStore = require('./createStore')
  , Q = require('q');

var OneDriveStore = createStore({
  isLoading: false,
  accessToken: null,
  user: null,
  isAuthenticating: false,
  defaultDisplayName: 'None',
  rootUrl: null,
  mountPath: null,
  previousUri: null,
  uri: null,
  authRedirectUrl: null,
  status: '',
  statusCode: 0
});

OneDriveStore.setup = function(rootUrl, mountPath) {
  this.setState({
    rootUrl: rootUrl,
    mountPath: mountPath
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

/**
 * Public: Perform authorization against Rails to determine if the user
 *         is able to access their files
 *
 * Returns Promise
 */
OneDriveStore.authorizeOneDrive = function() {
  this.setState({ status: 'Authorizing...'});
  return axios({
    url: this.getState().rootUrl + 'api/v1/skydrive_authorized',
    headers: this.authHeaders()
  });
};

/**
 * Public: Set the new uri and trigger the files to be fetched.
 *
 * Returns nothing
 */
OneDriveStore.changeUri = function(newUri) {
  var currentUri = this.getState().uri;
  this.setState({
    uri: newUri,
    previousUri: currentUri
  });
  this.fetchFiles();
};

/**
 * Private: Get user information from Rails
 *
 * Returns Object user
 */
OneDriveStore.fetchUser = function() {
  this.setState({ status: 'Fetching user data...'});
  axios({
    url: this.getState().rootUrl + 'api/v1/users/self',
    headers: this.authHeaders()
  }).then(this.setUser.bind(this))
    .catch(this.reset.bind(this));
};

/**
 * Private: Resets the access token and user
 *
 * Returns nothing
 */
OneDriveStore.reset = function(response) {
  this.setState({
    accessToken: null,
    user: null
  });
};

/**
 * Private: Sets the user into the state
 *
 * Returns Object user
 */
OneDriveStore.setUser = function(response) {
  this.setState({
    status: 'Loaded user data',
    user: response.data
  });
  return this.getState().user;
};

/**
 * Private: Fetch files and folders from Rails
 *
 * Returns nothing
 */
OneDriveStore.fetchFiles = function() {
  if (this.getState().data && (this.getState().uri === this.getState().previousUri)) { return; }
  this.setState({ isLoading: true, status: 'Fetching files and folders' });

  var request = $.ajax({
    url: this.getState().rootUrl + 'api/v1/files/?uri=' + (this.getState().uri || 'root'),
    type: 'GET',
    headers: this.authHeaders()
  });

  request.done(function(data) {
    this.setState({
      data: data,
      isLoading: false,
      authRedirectUrl: null,
      statusCode: 1,
      status: 'Authorized!'
    });
  }.bind(this));

  request.fail(function() {
    this.setState({
      isLoading: false,
      statusCode: -1,
      status: 'Unable to authorize'
    });
  }.bind(this));
};

/**
 * Private: Helper method which generates the auth headers
 *
 * Returns Object headers
 */
OneDriveStore.authHeaders = function() {
  return { 'Authorization': 'Bearer ' + (this.getState().accessToken || 'none') };
};

module.exports = OneDriveStore;