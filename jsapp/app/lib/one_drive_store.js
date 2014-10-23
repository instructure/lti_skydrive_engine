var _ = require('lodash')
  , $ = require('jquery')
  , axios = require('axios')
  , baseUrl = 'http://localhost:3001/skydrive/'; // This should be loaded via window.ENV

var OneDriveStore = module.exports = {
  accessToken: null,
  userName: null,
  isAuthenticating: false,
  defaultDisplayName: 'None',

  // Determine if the user is currently authenticated.
  isAuthenticated: function() {
    return !_.isEmpty(this.accessToken);
  },

  // display name helper
  currentDisplayName: function() {
    return this.userName || this.defaultDisplayName;
  },

  authenticateWithCode: function(code) {
    this.isAuthenticating = true;

    var success = function(response) {
      window.response = response;
      var apiKey = response.data.api_key;
      if (!_.isEmpty(apiKey)) {
        this.authenticate(response.data.api_key.access_token);
      } else {
        this.authenticateWithCookie();
      }
      this.isAuthenticating = false;
    };

    var error = function(response) {
      this.authenticateWithCookie();
      this.isAuthenticating = false;
    };

    axios.post(baseUrl + 'oauth2/token', {code: code})
      .then(success.bind(this))
      .catch(error.bind(this));
  },

  cookieToken: function() {
    $.cookie('access_token');
  },

  authenticateWithCookie: function() {
    this.isAuthenticating = true;

    var accessToken = this.cookieToken();

    console.log("COOKIE TOKEN: ", accessToken);

    if (!_.isEmpty(accessToken)) {
      this.authenticate(accessToken);
    }
    this.isAuthenticating = false;
  },

  authenticate: function(token) {

  }
};