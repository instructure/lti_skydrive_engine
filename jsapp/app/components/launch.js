/** @jsx React.DOM */

var React = require('react');
var store = require('../lib/OneDriveStore');
var Spinner = require('./Spinner');
var Navigation = require('react-router').Navigation;

var Launch = module.exports = React.createClass({
  mixins: [Navigation],

  componentDidMount: function() {
    store.authenticateWithCode(this.props.params.code).then(
      function() {
        store.authorizeOneDrive().then(
          function(response) {
            store.setState({ authRedirectUrl: null });
            this.transitionTo(store.getState().mountPath + 'files?uri=root');
          }.bind(this),
          function(response) {
            store.setState({ authRedirectUrl: response.data });
            this.transitionTo('login');
          }.bind(this)
        );
      }.bind(this),
      function(data) {
        this.transitionTo('auth-failed');
      }.bind(this)
    );
  },

  render: function() {
    return (
      <div>
        <Spinner />
      </div>
    );
  }
});

