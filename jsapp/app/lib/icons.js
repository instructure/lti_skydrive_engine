var folderIcon     = require('../images/icon-folder.png');
var folderBackIcon = require('../images/icon-folder-back.png');
var fileIcon       = require('../images/icon-file.png');
var jpgIcon        = require('../images/icon-jpg.png');
var pdfIcon        = require('../images/icon-pdf.png');
var pngIcon        = require('../images/icon-png.png');
var wordIcon       = require('../images/icon-word.png');
var downloadIcon   = require('../images/download.svg');

var iconMap = {
  'folder': folderIcon,
  'file': fileIcon,
  'jpg': jpgIcon,
  'pdf': pdfIcon,
  'png': pngIcon,
  'word': wordIcon
};

module.exports = {
  folderIcon: folderIcon,
  fileIcon: fileIcon,
  jpgIcon: jpgIcon,
  pdfIcon: pdfIcon,
  pngIcon: pngIcon,
  wordIcon: wordIcon,
  iconMap: iconMap,
  folderBackIcon: folderBackIcon,
  downloadIcon: downloadIcon
};