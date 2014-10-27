var React = require('react')
  , makeStubbedDescriptor = require('../../__tests__/makeStubbedDescriptor')
  , History = require('../History')
  , store = require('../../lib/OneDriveStore');

describe('History', function() {
  describe('when files guid is not available', function() {
    it('does not show any breadcrumbs', function(done) {
      store.setState({ filesGuid: null });
      var component = React.renderComponent(makeStubbedDescriptor(History, {}), document.createElement('div'));
      assert(component.getDOMNode().querySelectorAll('.breadcrumb li').length === 1, 'There are no breadcrumbs');
      done();
    });
  });
});

