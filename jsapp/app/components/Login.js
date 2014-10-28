/** @jsx React.DOM */

var React = require('react');
var store = require('../lib/OneDriveStore');
var Navigation = require('react-router').Navigation;

var Login = module.exports = React.createClass({
  mixins: [Navigation],

  getInitialState: function() {
    return store.getState();
  },

  onChange: function() {
    this.setState(store.getState());
  },

  componentDidMount: function() {
    store.addChangeListener(this.onChange);
  },

  componentWillUnmount: function() {
    store.removeChangeListener(this.onChange);
  },

  openAuthPopup: function() {
    var popup = window.open(store.getState().authRedirectUrl, 'auth', 'width=795,height=500');
    window.completeLogin = this.completeLogin;
    store.setState({ popupWindow: popup });
  },

  completeLogin: function() {
    this.transitionTo(store.getState().mountPath + 'files?uri=root');
  },

  render: function() {
    return (
      <div className="Login">
        <p className="text-center">You must first log into your OneDrive account.</p>
        <div className="text-center">
          <button className="btn btn-lg btn-primary" onClick={this.openAuthPopup}>Login</button>
        </div>
      </div>
    );
  }
});

