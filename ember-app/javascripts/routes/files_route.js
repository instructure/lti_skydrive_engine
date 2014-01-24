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
    path = Ember.ENV.CONFIG.root_path;
    controller.set('isLoading', true);
    var skydriveAuthorized = Ember.$.getJSON(path + 'api/v1/skydrive_authorized').then(
      function() {
        Ember.$.getJSON(path + 'api/v1/files/' + uri).then(
          function(data) {
            controller.set('model', data);
            controller.set('isLoading', false);
          },
          function(jqxhr) {
            controller.set('model', {});
            controller.set('authRedirectUrl', jqxhr.responseText);
            controller.set('isLoading', false);
          }
        );
        controller.set('authRedirectUrl', null);
      },
      function(jqxhr) {
        controller.set('model', {});
        controller.set('authRedirectUrl', jqxhr.responseText);
        controller.set('isLoading', false);
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
      path = Ember.ENV.CONFIG.root_path;
      ctrl.set('authRedirectUrl', null);
      ctrl.set('popupWindow', null);
      ctrl.set('isLoading', true);
      Ember.$.getJSON(path + 'api/v1/files').then(
        function(data) {
          ctrl.set('model', data); 
          ctrl.set('isLoading', false);
        },

        // The user did not authorize Microsoft
        function(jqxhr) {
          Ember.$.getJSON(path + 'api/v1/skydrive_authorized').then(
            function(data) {},
            function(jqxhr) {
              ctrl.set('model', {});
              ctrl.set('authRedirectUrl', jqxhr.responseText);
              ctrl.set('isLoading', false);
            }.bind(this)
          );
        }.bind(this)
       );
    }
  }
});

module.exports = FilesRoute;

