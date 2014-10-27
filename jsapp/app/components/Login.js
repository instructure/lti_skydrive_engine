/** @jsx React.DOM */

var React = require('react');

var store = require('../lib/OneDriveStore');

var Login = module.exports = React.createClass({
  getInitialState: function() {
    return store.getState();
  },

  onChange: function() {
    this.setState(store.getState());
  },

  componentDidMount: function() {
    store.addChangeListener(this.onChange);
    store.authorizeOneDrive().then(
      function(files) {
        console.log(files);
      },
      function(authRedirectUrl) {
        console.log(authRedirectUrl);
      }
    );
  },

  componentWillUnmount: function() {
    store.removeChangeListener(this.onChange);
  },

  render: function() {
    return (
      <div className="Login">
        <p className="text-center">You must first log into your OneDrive account.</p>
        <div className="text-center">
          <button className="btn btn-lg btn-primary">Login</button>
        </div>
      </div>
    );
  }
});

