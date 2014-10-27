/** @jsx React.DOM */

var React = require('react');

var Index   = require('./Index');
var Banner  = require('./Banner');
var History = require('./History');

var App = module.exports = React.createClass({

  render: function() {
    var content = this.props.activeRouteHandler() || <Index />;
    return (
      <div id="wrapper">
        <Banner />
        <History />
        {content}
      </div>
    );
  }

});

