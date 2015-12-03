
backbone = require 'backbone'
_ = require 'underscore'
$ = require 'jquery'
bootbox = require 'bootbox'
OrgUserView = require './OrgUserView'
spinner = require './Spinner'
require 'select2'

module.exports = backbone.View.extend
  initialize : (options) ->
    @host = options.host
    @orgGuid = options.orgGuid
    @orgName = options.orgName
    @userName = options.userName


  render : ->

    table = $("<table class=\"table table-bordered table-striped\"></table>")
    row = $("<tr></tr>")
    row.append $("<th >User Id</th>")
    row.append $("<th>Org Developer</th>")
    row.append $("<th>Org Manager</th>")
    row.append  $("<th>Org Auditor</th>")
    table.append(row)
    @.$el.append(table)
    spinner.blockUI()
    auditorRequest = $.ajax
      url: "https://#{@host}/cf-users/cf-api/organizations/#{@orgGuid}/auditors"
    managerRequest = $.ajax
      url: "https://#{@host}/cf-users/cf-api/organizations/#{@orgGuid}/managers"
    orgUserRequest = $.ajax
      url: "https://#{@host}/cf-users/cf-api/organizations/#{@orgGuid}/users"

    userRequest = $.ajax
      url:"https://#{@host}/cf-users/cf-api/users"

    success = (auditorData,managerData,orgUserData,userData) =>
        auditors = {}
        for auditor in auditorData[0].resources
          auditors[auditor.entity.username] = true
        managers = {}
        for manager in managerData[0].resources
          managers[ manager.entity.username] = true
        @isOrgManager = ((manager for manager in managerData[0].resources when manager.entity.username is @userName ).length > 0)
        orgUsers = {}
        for orgUser in orgUserData[0].resources
          orgUsers[orgUser.entity.username] = true
        userViews = (new OrgUserView({host: @host,orgGuid : @orgGuid, userName: user.entity.username, userGuid : user.metadata.guid, isManager : managers[user.entity.username], isAuditor : auditors[user.entity.username], isOrgUser : orgUsers[user.entity.username], userIsOrgManager: @isOrgManager}) for user in userData[0].resources)
        userViews = userViews.filter (a) ->
          a.userName
        userViews.sort (a,b) ->
          a.userName.toLowerCase().localeCompare(b.userName.toLowerCase())
        for userView in userViews
          userView.render()
          table.append(userView.$el)
        spinner.unblockUI()


    failure = (XMLHttpRequest, textStatus, errorThrown) =>
       spinner.unblockUI()
       @handleError(XMLHttpRequest, textStatus, errorThrown)


    $.when(auditorRequest,managerRequest,orgUserRequest,userRequest).then success, failure
  handleError : (XMLHttpRequest, textStatus, errorThrown)->
    if(XMLHttpRequest.status ==403)
       bootbox.alert(XMLHttpRequest.responseJSON.description)