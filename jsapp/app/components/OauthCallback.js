/** @jsx React.DOM */

var React = require('react');

var OauthCallback = module.exports = React.createClass({
  componentDidMount: function() {
    window.opener.completeLogin();
    window.close();
  },

  render: function() {
    return (
      <h5 className="text-center">This window should close automatically...</h5>
    );
  }
});
