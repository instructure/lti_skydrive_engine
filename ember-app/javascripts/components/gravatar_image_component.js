var md5 = require('../vendor/md5.min').md5;

var GravatarImageComponent = Ember.Component.extend({
  gravatarUrl: function() {
    return "http://www.gravatar.com/avatar/" + md5(this.get('email')) + "?s=" + this.getWithDefault('s', '30');
  }.property('email')
});

module.exports = GravatarImageComponent;

