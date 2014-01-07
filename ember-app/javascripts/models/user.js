var User = Ember.Model.extend({
  name:     Ember.attr(),
  email:    Ember.attr(),
  username: Ember.attr(),

  errors: {}
});

User.reopenClass({
  url:            "/skydrive/api/v1/users",
  adapter:        Ember.RESTAdapter.create(),
  rootKey:        "user",
  collectionKey:  "users",

  //Helper method for retrieving the current user from the API
  currentUser: function() {
    var record = this.cachedRecordForId('self');

    if (!Ember.get(record, 'isLoaded')) {
      User._fetchById(record, 'self').then(function(){
        record.set('id', record.data.id);
        User.recordCache[record.id] = record;
        record._reference.id=record.id;
      })
    }
    return record;
  }
});

module.exports = User;
