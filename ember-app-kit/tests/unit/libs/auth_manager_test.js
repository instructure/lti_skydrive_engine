/* global fakeServer, ic, sinon */

import AuthManager from 'appkit/libs/auth_manager';
import ajax from 'appkit/utils/ajax';

var authManager, apiKey;

module('Unit - AuthManager', {
  setup: function() {
    authManager = AuthManager.create();
    apiKey = Em.Object.create({ accessToken: 'ABCDE', user: { name: 'Joe' }});
  },
  teardown: function() {}
});

test('.currentDisplayName', function() {
  expect(2);
 
  equal(authManager.get('currentDisplayName'), 'None', 'display name is None');
  authManager.set('apiKey', apiKey);
  equal(authManager.get('currentDisplayName'), 'Joe', 'display name is Joe');
});

test('.isAuthenticated when no access token', function() {
  expect(2);

  equal(authManager.isAuthenticated(), false, 'not authenticated');
  authManager.set('apiKey', apiKey);
  equal(authManager.isAuthenticated(), true, 'is authenticated');
});

test('.authenticateWithCode with token response', function() {
  expect(1);

  var code = 'ABCDE',
      server = fakeServer('POST', 'oauth/token', { api_key: { access_token: 'DEFGH' }}),
      mockAuthManager = sinon.mock(authManager),
      expectation = mockAuthManager.expects("authenticate").once().withArgs("DEFGH");

  authManager.authenticateWithCode(code);
  server.respond();
  server.restore();

  ok(expectation.verify(), "authenticate('DEFGH') was called");
});

test('.authenticateWithCode without a token response', function() {
  expect(1);

  var code = 'ABCDE',
      server = fakeServer('POST', 'oauth/token', { api_key: null }),
      mockAuthManager = sinon.mock(authManager),
      expectation = mockAuthManager.expects("authenticateWithCookie").once();

  authManager.authenticateWithCode(code);
  server.respond();
  server.restore();
  
  ok(expectation.verify(), "authenticateWithCookie() was called");
});

test('.authenticateWithCookie', sinon.test(function() {
  var mockAuthManager = sinon.mock(authManager),
      expectation = mockAuthManager.expects('authenticate').withExactArgs('COOKIE_VALUE');

  sinon.stub($, "cookie").returns('COOKIE_VALUE');
  
  authManager.authenticateWithCookie();
  ok(expectation.verify(), "authenticate('COOKIE_VALUE') was called");
}));

test('.authenticate', function() {
  expect(2);

  var url = Ember.ENV.CONFIG.root_path + 'api/v1/users';
  var server = fakeServer('GET', url, {
    user: {
      id: 1,
      name: 'Eric',
      email: 'ericb@instructure.com',
      username: 'cavneb'
    }
  });

  authManager.authenticate('ACCESS_TOKEN');

  server.respond();
  equal(authManager.get('apiKey.user.name'), 'Eric', 'User name is Eric');
  equal(authManager.get('apiKey.accessToken'), 'ACCESS_TOKEN', 'Access token is ACCESS_TOKEN');
  server.restore();
});

test('.reset', function() {});
test('.apiKeyObserver', function() {});
