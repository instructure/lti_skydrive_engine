/** @jsx React.DOM */

var React = require('react');

var MicrosoftAuthFailed = module.exports = React.createClass({
  render: function() {
    return (
      <div className="MicrosoftAuthFailed text-center">
        <p>There was an issue authenticating your account with OneDrive.</p>
      </div>
    );
  }
});
