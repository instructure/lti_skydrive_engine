import ajax from 'appkit/utils/ajax';

var User = Ember.Object.extend({
  name: null,
  email: null,
  username: null
});

User.reopenClass({
  fetchCurrentUser: function() {
    var url = Ember.ENV.CONFIG.root_path + 'api/v1/users';
    return ajax(url, { id: 'self' }).then(function(result) {
      return User.create(result.user);
    });
  }
});

export default User;
