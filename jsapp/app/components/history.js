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

  goToParent: function(e) {
    e.preventDefault();
    store.changeUri(store.getState().data.parent_uri.uri);
  },

  render: function() {
    var parentLink = function() {
      if (store.getState().data && store.getState().data.parent_uri) {
        return (
          <li>
            <a onClick={this.goToParent} href="#">&hellip;</a>
          </li>
        );
      }
    }.bind(this);

    if (store.getState().uri && store.getState().data) {
      return (
        <div className="History">
          <ol className="breadcrumb">
            <li className="pull-right">{store.getState().currentDisplayName}</li>
            {parentLink()}
            <li className="active">{store.getState().data.name}</li>
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

