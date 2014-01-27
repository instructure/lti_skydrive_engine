import AuthManager from 'appkit/libs/auth_manager';

var LaunchRoute = Ember.Route.extend({
  setupController: function(controller, model) {
    var code = model.code;
    if (code === 'na') {
      code = null;
    }

    if (Ember.isEmpty(code)) {
      AuthManager.authenticateWithCookie();
    } else {
      AuthManager.authenticateWithCode(code);
    }

    return {};
  }
});

export default LaunchRoute;
