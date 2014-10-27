/** @jsx React.DOM */

var React = require('react')
  , store = require('../lib/OneDriveStore');

var History = module.exports = React.createClass({
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

  render: function() {
    if (this.state.filesGuid) {
      return (
        <div className="History">
          <ol className="breadcrumb">
            <li><a href="#">Documents</a></li>
            <li><a href="#">Library</a></li>
            <li className="active">Data</li>
          </ol>
        </div>
      );
    } else {
      return (
        <div className="History">
          <ol className="breadcrumb">
            <li>&nbsp;</li>
          </ol>
        </div>
      );
    }

  }
});

