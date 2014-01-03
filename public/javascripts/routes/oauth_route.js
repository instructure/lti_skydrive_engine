var OauthRoute = Ember.Route.extend({
  setupController: function() {
    window.opener.App.__container__.lookup('route:files').send('completedAuth');
  }
});

module.exports = OauthRoute;

