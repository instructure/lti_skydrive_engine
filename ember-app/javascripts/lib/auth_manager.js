var User = require('../models/user');

var AuthManager = Ember.Object.extend({

  // Load the current user if we have a cookie or an oauth2 code
  // init: function() {
  //   this._super();

  //   var code = $.url().param('code');

  //   if(!Ember.isEmpty(code)) {
  //     this.authenticateWithCode(code);
  //   } else {
  //     this.authenticateWithCookie();
  //   }
  // },

  currentDisplayName: function() {
    return this.get('apiKey.user.name') || 'None';
  }.property('apiKey.user.name'),

  // Determine if the user is currently authenticated.
  isAuthenticated: function() {
    return !Ember.isEmpty(this.get('apiKey.accessToken'));
  },

  authenticateWithCode: function(code) {
    $.post('oauth2/token', {code: code})
      .always($.proxy(function(response) {
        if(!Ember.isEmpty(response.api_key)){
          this.authenticate(response.api_key.access_token);
        } else {
          this.authenticateWithCookie();
        }
      }, this));
  },

  authenticateWithCookie: function() {
    var accessToken = $.cookie('access_token');
    if (!Ember.isEmpty(accessToken)) {
      this.authenticate(accessToken);
    }
  },

  // Authenticate the user. Once they are authenticated, set the access token to be submitted with all
  // future AJAX requests to the server.
  authenticate: function(accessToken) {
    $.ajaxSetup({
      headers: { 'Authorization': 'Bearer ' + accessToken }
    });

    Ember.loadPromise(User.currentUser())
      .then($.proxy(function(user){
        this.set('apiKey', App.ApiKey.create({
          accessToken: accessToken,
          user: user
        }));
      }, this));
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

//Reset the authentication if any ember data request returns a 401 unauthorized error
//DS.rejectionHandler = function(reason) {
//  if (reason.status === 401) {
//    App.AuthManager.reset();
//  }
//  throw reason;
//};

module.exports = AuthManager;
