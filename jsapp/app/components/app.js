/** @jsx React.DOM */

var React = require('react');

var App = module.exports = React.createClass({

  render: function() {
    return (
      <div className="container">
        {this.props.activeRouteHandler()}
      </div>
    );
  },

  renderIndex: function() {
    return (
      <div>
        <h2>Index</h2>
      </div>
    );
  }

});

