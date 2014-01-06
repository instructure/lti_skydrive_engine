var LaunchController = Ember.Controller.extend({
  authenticatedObserver: function() {
    if (App.AuthManager.isAuthenticated()) {
      this.transitionToRoute('files', {guid: 'root'});
    }
  }.observes('App.AuthManager.apiKey.accessToken')
});

module.exports = LaunchController;

