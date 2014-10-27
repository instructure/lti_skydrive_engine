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
          function(results) {
            this.transitionTo('files');
          }.bind(this),
          function(err) {
            debugger;
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

