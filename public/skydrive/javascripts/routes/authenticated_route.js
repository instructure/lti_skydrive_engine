var AuthenticatedRoute = Ember.Route.extend({
  beforeModel: function(transition) {
    if (!App.AuthManager.isAuthenticated()) {
      this.redirectToLaunch(transition);
    }
  },

  redirectToLaunch: function(transition) {
    this.transitionTo('launch', 'na');
  },

  events: {
    error: function(reason, transition) {
      this.redirectToLaunch(transition);
    }
  }
});

module.exports = AuthenticatedRoute;