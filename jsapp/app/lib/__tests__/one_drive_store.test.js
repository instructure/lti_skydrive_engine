var store = require('../one_drive_store')
  , server = null;

describe('OneDriveStore', function () {
  describe('#isAuthenticated', function () {
    it('must be true when accessToken is present', function () {
      store.accessToken = 'TOKEN';
      assert(store.isAuthenticated());
    });

    it('must be false when accessToken is not present', function () {
      store.accessToken = '';
      assert(!store.isAuthenticated());

      store.accessToken = null;
      assert(!store.isAuthenticated());
    });
  });

  describe('#currentDisplayName', function() {
    it('returns a real name if present', function() {
      store.userName = 'Hillary Duff';
      assert(store.currentDisplayName() === 'Hillary Duff');
    });

    it('returns a default name if not present', function() {
      store.userName = '';
      assert(store.currentDisplayName() === store.defaultDisplayName);

      store.userName = null;
      assert(store.currentDisplayName() === store.defaultDisplayName);
    });
  });

  describe('#authenticateWithCode', function() {
    describe('when a token is returned', function() {

      beforeEach(function() {
        server = sinon.fakeServer.create();
      });

      afterEach(function() {
        server.restore();
      });

      it('must call authenticate with the returned token', function(done) {
        store.authenticate = function(code) {
          assert(code === 'ACCESS_TOKEN', 'authenticate was called!');
          done();
        };

        store.authenticateWithCode('CODE');

        server.requests[0].respond(
          201,
          { 'Content-Type': 'application/json' },
          '{"api_key":{"access_token":"ACCESS_TOKEN"}}'
        );
      });

      it('must call authenticateWithCookie when response is 400', function(done) {
        store.authenticateWithCookie = function() {
          assert(true, 'authenticateWithCookie was called!');
          done();
        };

        store.authenticateWithCode('CODE');

        server.requests[0].respond(
          400,
          { 'Content-Type': 'application/json' },
          '{"message":"invalid code"}'
        );
      });
    });
  });

  describe('#authenticateWithCookie', function() {
    describe('when a cookie is present', function() {
      it('must call authenticate', function(done) {
        store.cookieToken = function() { return 'ACCESS_TOKEN' };

        store.authenticate = function(code) {
          assert(code === 'ACCESS_TOKEN', 'authenticate was called!');
          done();
        };

        store.authenticateWithCookie();
      });
    });

    describe('when a cookie is not present', function() {
      it('must not call authenticate', function() {
        it('must call authenticate', function(done) {
          store.cookieToken = function() { return '' };

          store.authenticate = function(code) {
            assert(false, 'authenticate was called!');
            done();
          };

          store.authenticateWithCookie();
        });
      });
    });
  });
});
