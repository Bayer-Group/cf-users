
backbone = require 'backbone'
_ = require 'underscore'
$ = require 'jquery'
require '../../../bower_components/growl/javascripts/jquery.growl'
require 'select2'
bootbox = require('bootbox')

module.exports = backbone.View.extend
  initialize : (options) ->
    @host = options.host
    @orgGuid = options.orgGuid
    @userGuid = options.userGuid
    @userName = options.userName
    @isManager = options.isManager
    @isAuditor = options.isAuditor
    @isOrgUser= options.isOrgUser
    @userIsOrgManager = options.userIsOrgManager

  tagName : 'tr'

  events :
    'click .org-manager' : 'managerChanged'
    'click .org-auditor' : 'auditChanged'
    'click .org-user' : 'userChanged'
  render : ->

    @$el.append $("<td>#{@userName}</td>")
    @$el.append $("<td><input class=\"org-user\" type=\"checkbox\" #{if(@isOrgUser) then 'checked' else ""  } #{if(@userIsOrgManager) then "" else "disabled"} /></td>")
    @$el.append $("<td><input class=\"org-manager\" type=\"checkbox\" #{if(@isManager) then 'checked' else ""  } #{if(@userIsOrgManager) then "" else "disabled"}/></td>")
    @$el.append  $("<td><input class=\"org-auditor\" type=\"checkbox\"  #{if(@isAuditor) then 'checked' else "" } #{if(@userIsOrgManager) then "" else "disabled"}/></td>")
    @$el

  auditChanged : (e)->
    if(@$('.org-auditor').is(':checked'))
      $.ajax
        url: "https://#{@host}/cf-users/cf-api/organizations/#{@orgGuid}/auditors/#{@userGuid}"
        method : "PUT"
        success : $.growl.notice({message :"#{@userName} role auditor added for organization."})
        error: (XMLHttpRequest, textStatus, errorThrown) =>
          @$('.org-auditor').attr('checked',false)
          $.growl.error({message :"#{@userName} auditor role change failed for organization."})

    else
      $.ajax
        url: "https://#{@host}/cf-users/cf-api/organizations/#{@orgGuid}/auditors/#{@userGuid}"
        method : "DELETE"
        success : $.growl.notice({message :"#{@userName}  auditor role removed for organization."})
        error: (XMLHttpRequest, textStatus, errorThrown) =>
          @$('.org-auditor').attr('checked',true)
          $.growl.error({message :"#{@userName} auditor role change failed for organization."})

  userChanged : (e)->
    if(@$('.org-user').is(':checked'))
      $.ajax
        url: "https://#{@host}/cf-users/cf-api/organizations/#{@orgGuid}/users/#{@userGuid}"
        method : "PUT"
        success : $.growl.notice({message :"#{@userName} developer role added for organization."})
        error: (XMLHttpRequest, textStatus, errorThrown) =>
          @$('.org-user').attr('checked',false)
          $.growl.error({message :"#{@userName} developer role change failed for organization."})
    else
      $.ajax
        url: "https://#{@host}/cf-users/cf-api/organizations/#{@orgGuid}/users/#{@userGuid}"
        method : "DELETE"
        success : $.growl.notice({message :"#{@userName} developer role removed for organization."})
        error: (XMLHttpRequest, textStatus, errorThrown) =>
          @$('.org-user').attr('checked',true)
          $.growl.error({message :"#{@userName} developer role change failed for organization."})


  managerChanged: (e) ->
    if(@$('.org-manager').is(':checked'))
      $.ajax
        url: "https://#{@host}/cf-users/cf-api/organizations/#{@orgGuid}/managers/#{@userGuid}"
        method : "PUT"
        success : $.growl.notice({message :"#{@userName} manager role added for organization."})
        error: (XMLHttpRequest, textStatus, errorThrown) =>
          @$('.org-manager').attr('checked',false)
          $.growl.error({message :"#{@userName} manager role change failed for organization."})

    else
      $.ajax
        url: "https://#{@host}/cf-users/cf-api/organizations/#{@orgGuid}/managers/#{@userGuid}"
        method : "DELETE"
        success : $.growl.notice({message :"#{@userName} manager role removed for organization."})
        error: (XMLHttpRequest, textStatus, errorThrown) =>
          $.growl.error({message :"#{@userName} manager role change failed for organization."})
          @$('.org-manager').attr('checked',true)

