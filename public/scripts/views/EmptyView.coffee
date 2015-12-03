
backbone = require 'backbone'
_ = require 'underscore'
$ = require 'jquery'

module.exports = backbone.View.extend
  initialize : (options) ->
    @options = options
  render : ->
    @.$el.html "<div>&nbsp;</div>"