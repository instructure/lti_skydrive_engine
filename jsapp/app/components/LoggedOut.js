/** @jsx React.DOM */

var React = require('react');

var Index = module.exports = React.createClass({
  render: function() {
    return (
      <div className="text-center">
        <p>You have successfully logged out of one drive.</p>
        <p>Relaunch one drive to reauthorize</p>
      </div>
    );
  }
});
