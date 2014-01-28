var LaunchRoute = Ember.Route.extend({
  setupController: function(controller, model) {
    // THIS SHOULD BE CALLED IN THE TEST BUT IT'S NOT!
    debugger;
    this.authenticate(model.code);
    this._super.apply(arguments);
  },

  authenticate: function(code) {
    if (code === 'na') {
      code = null;
    }

    if (Ember.isEmpty(code)) {
      App.AuthManager.authenticateWithCookie();
    } else {
      App.AuthManager.authenticateWithCode(code);
    }
  }
});

export default LaunchRoute;
