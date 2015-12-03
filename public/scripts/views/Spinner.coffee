$ = require 'jquery'
require 'block-ui'
module.exports =
  blockUI: () ->
    $.blockUI
      message: '<img  src="/cf-users/images/spinner.gif"/>'
      css:
        width: '40px'
        height: '40px'
        top: ($(window).height() - 40) / 2 + 'px'
        left: ($(window).width() - 40) / 2 + 'px'
        background: 'rgba(02,02,02,0)'
        border: 0
        blockMsgClass: "spinner-block-message"
      overlayCSS:
        'background-color': 'rgb(02,02,02)'
        'opacity': 0.1
  unblockUI: () ->
    $.unblockUI()