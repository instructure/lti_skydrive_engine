/** @jsx React.DOM */

var React = require('react')
  , store = require('../lib/OneDriveStore')
  , iconMap = require('../lib/icons').iconMap;


var FileTableRow = module.exports = React.createClass({
  render: function() {
    debugger;
    return (
      <tr className="FileTableRow">
        <td>
          <img src={iconMap[this.props.file.icon || 'file']} className="icon" />
          <span className="filename">{this.props.file.name}</span></td>
        <td>{this.props.file.kind}</td>
        <td>{this.props.file.file_size}</td>
        <td className="text-right">
          <a className="btn btn-sm" style={{'text-decoration': 'none'}}>
            <i className="icon-signin icon-rotate-90 icon-large"></i>
          </a>
        </td>
      </tr>
    );
  }
});

