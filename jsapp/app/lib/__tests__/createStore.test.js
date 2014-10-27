var createStore = require('../createStore');

describe('createStore', function () {
  describe('#initialize', function() {
    it('set data into store', function() {
      var MyStore = createStore({name: 'Joe', age: 35});
      assert(MyStore.getState().name === 'Joe');
      assert(MyStore.getState().age === 35);
    });
  });

  describe('#setState', function() {
    it('sets the state and triggers an event emitter', function(done) {
      var MyStore = createStore({name: 'Joe', age: 35});

      var eventReceiver = function() {
        assert(this.getState().foo === 'bar');
        assert(this.getState().baz === 'bop');
        assert(true, 'event was triggered');
        done();
      };

      MyStore.addChangeListener(eventReceiver.bind(MyStore));

      MyStore.setState({
        foo: 'bar',
        baz: 'bop'
      });
    })
  });
});