/** @jsx React.DOM */

var React = require('react')
  , Navigation = require('react-router').Navigation
  , store = require('../lib/OneDriveStore')
  , FolderTableRow = require('./FolderTableRow')
  , ParentTableRow = require('./ParentTableRow')
  , FileTableRow = require('./FileTableRow')
  , Spinner = require('./Spinner');

var Files = module.exports = React.createClass({

  mixins: [ Navigation ],

  statics: {
    willTransitionTo: function(transition, params, query) {
      if (!store.isAuthenticated()) {
        transition.redirect('auth-failed');
      }
    }
  },

  getInitialState: function() {
    return store.getState();
  },

  onChange: function() {
    if (store.getState().statusCode === -1) {
      this.transitionTo('microsoft-auth-failed');
    } else {
      this.setState(store.getState());
    }
  },

  componentDidMount: function() {
    store.addChangeListener(this.onChange);
    store.changeUri(this.props.params.splat || 'root');
  },

  componentWillUnmount: function() {
    store.removeChangeListener(this.onChange);
  },

  render: function() {
    var folderRows = function() {
      if (store.getState().data) {
        return store.getState().data.folders.map(function(f, index) {
          return <FolderTableRow key={index} folder={f} />
        });
      }
    };

    var fileRows = function() {
      if (store.getState().data) {
        return store.getState().data.files.map(function(f, index) {
          return <FileTableRow key={index} file={f} />
        });
      }
    };

    var parentFolder = function() {
      if (store.getState().data) {
        if (store.getState().data.parent_uri) {
          return (
            <tbody>
              <ParentTableRow />
            </tbody>
          );
        }
      }
    };

    if (store.getState().isLoading) {
      return <Spinner />
    } else {
      return (
        <div className="Files">
          <table className="Files__List table table-striped table-bordered table-hover">
            <thead>
              <tr>
                <th>Name</th>
                <th>Kind</th>
                <th>Size (Kb)</th>
                <th></th>
              </tr>
            </thead>
            {parentFolder()}
            <tbody>{folderRows()}</tbody>
            <tbody>{fileRows()}</tbody>
          </table>
        </div>
      );
    }
  }
});

