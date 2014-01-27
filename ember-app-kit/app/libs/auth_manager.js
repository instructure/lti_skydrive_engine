import User from 'appkit/models/user';
import ApiKey from 'appkit/models/api_key';
import ajax from 'appkit/utils/ajax';

var AuthManager = Ember.Object.extend({

  currentDisplayName: function() {
    return this.get('apiKey.user.name') || 'None';
  }.property('apiKey.user.name'),

  // Determine if the user is currently authenticated.
  isAuthenticated: function() {
    return (!Ember.isEmpty(this.get('apiKey.accessToken')) && !this.get('isAuthenticating'));
  },

  authenticateWithCode: function(code) {
    this.set('isAuthenticating', true);
    ic.ajax.raw({
      type: 'POST',
      url: 'oauth/token',
      data: { code: code }
    }).then(function(result) {
      if(!Ember.isEmpty(result.response.api_key)){
        this.authenticate(result.response.api_key.access_token);
      } else {
        this.authenticateWithCookie();
      }
      this.set('isAuthenticating', false);
    }.bind(this));
  },

  authenticateWithCookie: function() {
    this.set('isAuthenticating', true);
    var accessToken = $.cookie('access_token');
    if (!Ember.isEmpty(accessToken)) {
      this.authenticate(accessToken);
    }
    this.set('isAuthenticating', false);
  },

  // Authenticate the user. Once they are authenticated, set the access token to be submitted with all
  // future AJAX requests to the server.
  authenticate: function(accessToken) {
    $.ajaxSetup({
      headers: { 'Authorization': 'Bearer ' + accessToken }
    });

    User.fetchCurrentUser().then(function(user) {
      this.set('apiKey', ApiKey.create({
        accessToken: accessToken,
        user: user
      }));
    }.bind(this));
  },

  // Log out the user
  reset: function() {
    this.set('apiKey', null);
    $.ajaxSetup({
      headers: { 'Authorization': 'Bearer none' }
    });
  },

  // Ensure that when the apiKey changes, we store the data in cookies in order for us to load
  // the user when the browser is refreshed.
  apiKeyObserver: function() {
    if (Ember.isEmpty(this.get('apiKey'))) {
      $.removeCookie('access_token');
    } else {
      $.cookie('access_token', this.get('apiKey.accessToken'));
    }
  }.observes('apiKey')

});

export default AuthManager;
