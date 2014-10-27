var React = require('react')
  , makeStubbedDescriptor = require('../../__tests__/makeStubbedDescriptor')
  , App = require('../App');

describe('App', function() {
  it('renders', function(done) {
    var app = React.renderComponent(makeStubbedDescriptor(App, { activeRouteHandler: function() {} }), document.createElement('div'));
    assert(app.getDOMNode().querySelectorAll('.Banner').length === 1, 'There is a banner');
    assert(app.getDOMNode().querySelectorAll('.History').length === 1, 'There is a history bar');
    done();
  });
});

