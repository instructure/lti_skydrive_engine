/** @jsx React.DOM */

var React = require('react');

var bannerImage = require('../images/banner-white.png');

var Banner = module.exports = React.createClass({
  render: function() {
    return (
      <div className="Banner">
        <img className="Banner__Logo" src={bannerImage} />
      </div>
    );
  }
});

