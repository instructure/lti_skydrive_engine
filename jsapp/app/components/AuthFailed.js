/** @jsx React.DOM */

var React = require('react');

var AuthFailed = module.exports = React.createClass({
  render: function() {
    return (
      <div className="AuthFailed text-center">
        <p>You're not in a system that supports automated LTI autentication.</p>
        <p>This is likely due to the app not being launched with an LMS iframe.</p>
      </div>
    );
  }
});

