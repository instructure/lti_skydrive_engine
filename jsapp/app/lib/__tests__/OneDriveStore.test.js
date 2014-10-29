var store = require('../OneDriveStore')
  , server = null;

describe('OneDriveStore', function () {
  describe('#isAuthenticated', function () {
    it('must be true when accessToken is present', function () {
      store.setState({accessToken: 'TOKEN'});
      assert(store.isAuthenticated());
    });

    it('must be false when accessToken is not present', function () {
      store.setState({accessToken: ''});
      assert(!store.isAuthenticated());

      store.setState({accessToken: null});
      assert(!store.isAuthenticated());
    });
  });

  describe('#currentDisplayName', function() {
    it('returns a real name if present', function() {
      store.setState({user: { name: 'Hillary Duff' }});
      assert(store.currentDisplayName() === 'Hillary Duff');
    });

    it('returns a default name if not present', function() {
      store.setState({user: { name: '' }});
      assert(store.currentDisplayName() === store.getState().defaultDisplayName);

      store.setState({user: null});
      assert(store.currentDisplayName() === store.getState().defaultDisplayName);
    });
  });

  describe('#authenticateWithCode', function() {
    beforeEach(function() {
      server = sinon.fakeServer.create();
      store.rootUrl = 'http://localhost:3001/skydrive/';
    });

    afterEach(function() {
      server.restore();
    });

    describe('when a token is returned', function() {
      it('must call authenticate with the returned token', function(done) {
        var _authenticate = store.authenticate;
        store.authenticate = function(code) {
          assert(code === 'ACCESS_TOKEN', 'authenticate was called!');
          store.authenticate = _authenticate;
          done();
        };

        store.authenticateWithCode('CODE');

        server.requests[0].respond(
          201,
          { 'Content-Type': 'application/json' },
          '{"api_key":{"access_token":"ACCESS_TOKEN"}}'
        );
      });
    });
  });

  describe('#authenticate', function() {
    it('must call fetchUser', function(done) {
      var _fetchUser = store.fetchUser;
      store.fetchUser = function() {
        assert(true, 'fetchUser was called!');
        store.fetchUser = _fetchUser;
        done();
      };

      store.authenticate('ACCESS_TOKEN');
    });
  });

  describe('#fetchUser', function() {
    beforeEach(function() {
      server = sinon.fakeServer.create();
      store.rootUrl = 'http://localhost:3001/skydrive/';
    });

    afterEach(function() {
      server.restore();
    });

    it('must fetch the user', function(done) {
      store.setState({ accessToken: 'ACCESS_TOKEN' });

      var _setUser = store.setUser;
      var _reset = store.reset;

      store.setUser = function(response) {
        store.setUser = _setUser;
        store.reset = _reset;
        assert(response.data.username === 'cavneb', 'user was set');
        done();
      };

      store.reset = function(response) {
        store.setUser = _setUser;
        store.reset = _reset;
        assert(false, 'reset was called!');
        done();
      };

      store.fetchUser();

      server.requests[0].respond(
        200,
        { 'Content-Type': 'application/json' },
        '{"id":1,"name":"Eric Berry","username":"cavneb","email":"cavneb@gmail.com"}'
      );
    });
  });
});
