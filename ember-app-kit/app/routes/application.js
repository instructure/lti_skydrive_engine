import AuthManager from 'appkit/libs/auth_manager';

var ApplicationRoute = Ember.Route.extend({
  init: function() {
    this._super();
    App.AuthManager = AuthManager.create();
  }
});

export default ApplicationRoute;
