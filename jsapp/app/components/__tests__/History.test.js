var React = require('react')
  , makeStubbedDescriptor = require('../../__tests__/makeStubbedDescriptor')
  , History = require('../History')
  , store = require('../../lib/OneDriveStore')
  , filesWithoutParent = require('../../__tests__/stubs').filesWithoutParent()
  , filesWithParent = require('../../__tests__/stubs').filesWithParent();

describe('History', function() {
  describe('when files are not present', function() {
    it('does not show any breadcrumbs', function(done) {
      var _state = store.getState();
      store.setState({ data: { }, user: { name: 'Joe Blow' } });
      var component = React.renderComponent(makeStubbedDescriptor(History, {}), document.createElement('div'));
      assert(component.getDOMNode().querySelectorAll('.breadcrumb li').length === 1, 'There are no breadcrumbs');
      store.setState(_state);
      done();
    });
  });

  describe('when files are present', function() {
    describe('and there is not a parent uri', function() {
      it('shows breadcrumbs', function(done) {
        var _state = store.getState();
        store.setState({ data: filesWithoutParent, uri: 'foo', user: { name: 'Joe Blow' } });
        var component = React.renderComponent(makeStubbedDescriptor(History, {}), document.createElement('div'));
        assert(component.getDOMNode().querySelectorAll('.breadcrumb li').length === 2);
        store.setState(_state);
        done();
      });
    });

    describe('and there is a parent uri', function() {
      it('shows breadcrumbs', function(done) {
        var _state = store.getState();
        store.setState({ data: filesWithParent, uri: 'foo', user: { name: 'Joe Blow' } });
        var component = React.renderComponent(makeStubbedDescriptor(History, {}), document.createElement('div'));
        assert(component.getDOMNode().querySelectorAll('.breadcrumb li').length === 3);
        store.setState(_state);
        done();
      });
    });
  });
});

