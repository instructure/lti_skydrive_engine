/** @jsx React.DOM */

var React = require('react')
  , store = require('../lib/OneDriveStore')
  , folderBackIcon = require('../lib/icons').folderBackIcon;

var FolderTableRow = module.exports = React.createClass({
  goToParent: function(e) {
    e.preventDefault();
    store.changeUri(store.getState().data.parent_uri.uri);
  },

  render: function() {
    return (
      <tr className="ParentTableRow">
        <td>
          <a onClick={this.goToParent} href="#">
            <img src={folderBackIcon} className="icon" /> &hellip;
          </a>
        </td>
        <td>-</td>
        <td>-</td>
        <td>&nbsp;</td>
      </tr>
    );
  }
});

