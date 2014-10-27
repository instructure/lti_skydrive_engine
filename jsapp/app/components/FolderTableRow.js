/** @jsx React.DOM */

var React = require('react')
  , Navigation = require('react-router').Navigation
  , folderIcon = require('../lib/icons').folderIcon;

var FolderTableRow = module.exports = React.createClass({
  mixins: [Navigation],

  goToFolder: function(e) {
    e.preventDefault();
    this.transitionTo('files', { guid: this.props.folder.uri });
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

