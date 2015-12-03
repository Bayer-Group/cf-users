  backbone = require 'backbone'
  _ = require 'underscore'
  $ = require 'jquery'
  require '../../../bower_components/growl/javascripts/jquery.growl'
  require 'select2'
  bootbox = require('bootbox')

  module.exports = backbone.View.extend
    initialize : (options) ->
      @host = options.host
      @spaceGuid = options.spaceGuid
      @userGuid = options.userGuid
      @userName = options.userName
      @isManager = options.isManager
      @isAuditor = options.isAuditor
      @isDeveloper= options.isDeveloper
      @userIsSpaceManager = options.userIsSpaceManager

    tagName : "tr"
    events :
      'click .space-manager' : 'managerChanged'
      'click .space-auditor' : 'auditChanged'
      'click .space-developer' : 'developerChanged'

    render : ->

      @$el.append $("<td>#{@userName}</td>")
      @$el.append $("<td><input class=\"space-developer\" type=\"checkbox\" #{if(@isDeveloper) then 'checked' else ""  } #{if(@userIsSpaceManager) then "" else "disabled"} /></td>")
      @$el.append $("<td><input class=\"space-manager\" type=\"checkbox\" #{if(@isManager) then 'checked' else ""  } #{if(@userIsSpaceManager) then "" else "disabled"}/></td>")
      @$el.append  $("<td><input class=\"space-auditor\" type=\"checkbox\"  #{if(@isAuditor) then 'checked' else "" } #{if(@userIsSpaceManager) then "" else "disabled"}/></td>")
      @$el

    auditChanged : (e)->
      if(@$('.space-auditor').is(':checked'))
        $.ajax
          url: "https://#{@host}/cf-users/cf-api/spaces/#{@spaceGuid}/auditors/#{@userGuid}"
          method : "PUT"
          success : $.growl.notice({message :"#{@userName} role auditor added for space."})
          error: (XMLHttpRequest, textStatus, errorThrown) =>
            @$('.space-auditor').attr('checked',false)
            $.growl.error({message :"#{@userName} auditor role change failed for space."})

      else
        $.ajax
          url: "https://#{@host}/cf-users/cf-api/spaces/#{@spaceGuid}/auditors/#{@userGuid}"
          method : "DELETE"
          success : $.growl.notice({message :"#{@userName} role auditor removed for space."})
          error: (XMLHttpRequest, textStatus, errorThrown) =>
            @$('.space-auditor').attr('checked',true)
            $.growl.error({message :"#{@userName} auditor role change failed for space."})


    developerChanged : (e)->
      if(@$('.space-developer').is(':checked'))
        $.ajax
          url: "https://#{@host}/cf-users/cf-api/spaces/#{@spaceGuid}/developers/#{@userGuid}"
          method : "PUT"
          success : $.growl.notice({message :"#{@userName} role developer added for space."})
          error: (XMLHttpRequest, textStatus, errorThrown) =>
            @$('.space-developer').attr('checked',false)
            $.growl.error({message :"#{@userName} developer role change failed for space."})

      else
        $.ajax
          url: "https://#{@host}/cf-users/cf-api/spaces/#{@spaceGuid}/developers/#{@userGuid}"
          method : "DELETE"
          success : $.growl.notice({message :"#{@userName} role developer removed  for space."})
          error: (XMLHttpRequest, textStatus, errorThrown) =>
            @$('.space-developer').attr('checked',true)
            $.growl.error({message :"#{@userName} developer role change failed for space."})


    managerChanged: (e) ->
      if(@$('.space-manager').is(':checked'))
        $.ajax
          url: "https://#{@host}/cf-users/cf-api/spaces/#{@spaceGuid}/managers/#{@userGuid}"
          method : "PUT"
          success : $.growl.notice({message :"#{@userName} role manager added for space."})
          error: (XMLHttpRequest, textStatus, errorThrown) =>
            @$('.space-manager').attr('checked',false)
            $.growl.error({message :"#{@userName} manager role change failed for space."})
      else
        $.ajax
          url: "https://#{@host}/cf-users/cf-api/spaces/#{@spaceGuid}/managers/#{@userGuid}"
          method : "DELETE"
          success : $.growl.notice({message :"#{@userName} role manager removed for space."})
          error: (XMLHttpRequest, textStatus, errorThrown) =>
            @$('.space-manager').attr('checked',true)
            $.growl.error({message :"#{@userName} manager role change failed for space."})


