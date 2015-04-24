/** @jsx React.DOM */

var React = require('react')
  , store = require('../lib/OneDriveStore')
  , Navigation = require('react-router').Navigation;

var bannerImage = require('../images/banner-white.png');

var Banner = module.exports = React.createClass({
  mixins: [Navigation],

  getInitialState: function() {
    return {
      loggedIn: store.getState().statusCode == 1
    }
  },

  onChange: function() {
    this.setState({
      loggedIn: store.getState().statusCode == 1
    });
  },

  componentDidMount: function() {
    store.addChangeListener(this.onChange);
  },

  logout: function (){
    store.skydriveLogout();
    this.transitionTo('logged_out');
  },

  render: function() {
    return (
      <div className="Banner">
        <img className="Banner__Logo" src={bannerImage} />
        <a href="#" className={!this.state.loggedIn && 'hidden pull-right' || 'pull-right'} onClick={this.logout}>Logout</a>
      </div>
    );
  }
});
