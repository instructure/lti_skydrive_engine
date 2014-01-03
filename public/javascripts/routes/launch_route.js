var LaunchRoute = Ember.Route.extend({
  setupController: function() {
    var params = this.context;
    var code = params.code;
    if (code === 'na') {
      code = null;
    }
    if (!Ember.isEmpty(code)) {
      App.AuthManager.authenticateWithCode(params.code);
    } else {
      App.AuthManager.authenticateWithCookie();
    }
    return {};
  }
});

module.exports = LaunchRoute;

