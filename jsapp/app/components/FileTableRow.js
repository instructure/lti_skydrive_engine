/** @jsx React.DOM */

var React = require('react')
  , store = require('../lib/OneDriveStore')
  , iconMap = require('../lib/icons').iconMap;

var FileTableRow = module.exports = React.createClass({
  render: function() {
    return (
      <tr className={this.props.file.is_embeddable ? "FileTableRow" : "FileTableRow disabled"}>
        <td>
          <img src={iconMap[this.props.file.icon || 'file']} className="icon" />
          <span className="filename">{this.props.file.name}</span></td>
        <td>{this.props.file.kind}</td>
        <td>{this.props.file.file_size}</td>
        <td className="text-right">
          <a className="btn btn-sm btn-primary" href={this.props.file.homework_submission_url}>Attach</a>
        </td>
      </tr>
    );
  }
});

