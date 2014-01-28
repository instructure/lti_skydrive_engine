var App;

module('Acceptances - Launch', {
  setup: function(){
    App = startApp();
  },
  teardown: function() {
    Ember.run(App, 'destroy');
  }
});

test('displays the LTI not supported message if not launched as LTI app', function(){
  expect(1);

  visit('/launch/na');

  andThen(function(){
    var title = find('p');

    ok(title.text().match(/not in a system/), 'not supported message shown');
  });
});

//test('asdf', function() {

//});
