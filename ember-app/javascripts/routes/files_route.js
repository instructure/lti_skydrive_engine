var AuthenticatedRoute = require('./authenticated_route');

var FilesRoute = AuthenticatedRoute.extend({
  model: function(params) {
    return params;
  },

  serialize: function(model) {
    return { uri: model.uri };
  },

  setupController: function(controller, model) {
    var uri = model.uri;
    path = window.ENV.CONFIG.root_path;
    var skydriveAuthorized = Ember.$.getJSON(path + 'api/v1/skydrive_authorized').then(
      function() {
        controller.set('isLoading', true);
        Ember.$.getJSON('/skydrive/api/v1/files/' + uri).then(function(data) {
          controller.set('model', data);
          controller.set('isLoading', false);
        })
        controller.set('authRedirectUrl', null);
      },
      function(jqxhr) {
        controller.set('model', {});
        controller.set('authRedirectUrl', jqxhr.responseText);
      }
    );
  },

  events: {
    goToFolder: function(folder) {
      var uri = folder.uri;
      this.transitionTo('files', uri);
    },

    completedAuth: function() {
      var ctrl = this.get('controller');
      var popupWindow = ctrl.get('popupWindow');
      if (popupWindow) {
        popupWindow.close();
      }
      ctrl.set('authRedirectUrl', null);
      ctrl.set('popupWindow', null);
      ctrl.set('isLoading', true);
      ctrl.set('model', Ember.$.getJSON('/skydrive/api/v1/files').then(function(data) { 
        ctrl.set('model', data); 
        ctrl.set('isLoading', false);
      }));
    }
  }
});

module.exports = FilesRoute;

