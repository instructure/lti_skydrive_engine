var FilesController = Ember.ObjectController.extend({
  authRedirectUrl: null,
  popupWindow: null,
  parentFolder: null,
  isLoading: false,

  currentUser: function() {
    return App.AuthManager.get('apiKey.user');
  }.property('App.AuthManager.apiKey'),

  openAuthPopup: function() {
    var popup = window.open(this.get('authRedirectUrl'), 'auth', 'width=795,height=500');
    this.set('popupWindow', popup);
  }

});

module.exports = FilesController;

