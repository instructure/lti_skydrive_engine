var IndexRoute = Ember.Route.extend({
  redirect: function() {
    this.transitionTo('files', {uri: 'root'});
  }
});

module.exports = IndexRoute;

