/** @jsx React.DOM */

var React = require('react')
  , store = require('../lib/OneDriveStore')
  , folderIcon = require('../lib/icons').folderIcon;

var FolderTableRow = module.exports = React.createClass({
  goToFolder: function(e) {
    e.preventDefault();
    store.changeUri(this.props.folder.uri);
  },

  render: function() {
    return (
      <tr className="FolderTableRow">
        <td>
          <a onClick={this.goToFolder} href="#">
            <img src={folderIcon} className="icon" />
            <span className="filename">{this.props.folder.name}</span>
          </a>
        </td>
        <td>Folder</td>
        <td>-</td>
        <td>&nbsp;</td>
      </tr>
    );
  }
});

