
backbone = require 'backbone'
_ = require 'underscore'
$ = require 'jquery'
SpaceUserView = require './SpaceUserView'
require 'select2'
spinner = require './Spinner'

module.exports = backbone.View.extend
  initialize : (options) ->
    @host = options.host
    @orgGuid = options.orgGuid
    @spaceGuid = options.spaceGuid
    @spaceName = options.spaceName
    @orgName = options.orgName
    @userName = options.userName


  render : ->
    table = $("<table class=\"table table-bordered table-striped\"></table>")
    row = $("<tr></tr>")
    row.append $("<th>User Id</th>")
    row.append $("<th>Space Developer</th>")
    row.append $("<th>Space Manager</th>")
    row.append  $("<th>Space Auditor</th>")
    table.append(row)
    @.$el.append(table)
    spinner.blockUI()
    auditors = {}
    auditorRequest = $.ajax
      url: "https://#{@host}/cf-users/cf-api/spaces/#{@spaceGuid}/auditors"
    managers = {}
    managerRequest = $.ajax
      url: "https://#{@host}/cf-users/cf-api/spaces/#{@spaceGuid}/managers"
    developers  = {}
    developerRequest = $.ajax
      url: "https://#{@host}/cf-users/cf-api/spaces/#{@spaceGuid}/developers"

    orgManagerRequest = $.ajax
      url: "https://#{@host}/cf-users/cf-api/organizations/#{@orgGuid}/managers"

    orgUserCurrentPage = 1

    userViews = []
    orgUserHandler = (orgUserData) =>
      for user in orgUserData.resources
        userViews.push new SpaceUserView({host: @host,spaceGuid : @spaceGuid, userName: user.entity.username, userGuid : user.metadata.guid, isManager : managers[user.entity.username], isAuditor : auditors[user.entity.username],isDeveloper: developers[user.entity.username], userIsSpaceManager: @isSpaceManager ||  @isOrgManager})

      if (orgUserData.total_pages>orgUserCurrentPage)
        orgUserCurrentPage++
        $.ajax
          url:"https://#{@host}/cf-users/cf-api/organizations/#{@orgGuid}/users?page=#{orgUserCurrentPage}"
          success: orgUserHandler
          error : (XMLHttpRequest, textStatus, errorThrown) =>
            spinner.unblockUI()
            @handleError(XMLHttpRequest, textStatus, errorThrown)
      else

        userViews = userViews.filter (a) ->
          a.userName
        userViews.sort (a,b) ->
          a.userName.toLowerCase().localeCompare(b.userName.toLowerCase())
        for userView in userViews
          userView.render()
          table.append(userView.$el)
        spinner.unblockUI()

    orgUserRequest = $.ajax
      url: "https://#{@host}/cf-users/cf-api/organizations/#{@orgGuid}/users"

    success = (auditorData,managerData,developerData,orgUserData,orgManagerData) =>
        for auditor in auditorData[0].resources
          auditors[auditor.entity.username] = true
        for manager in managerData[0].resources
          managers[ manager.entity.username] = true
        for developer in developerData[0].resources
          developers[ developer.entity.username] = true
        @isSpaceManager = ((manager for manager in managerData[0].resources when manager.entity.username is @userName ).length > 0)
        @isOrgManager = ((manager for manager in orgManagerData[0].resources when manager.entity.username is @userName ).length > 0)
        orgUserHandler(orgUserData[0])
    failure = (XMLHttpRequest, textStatus, errorThrown) =>
      spinner.unblockUI()
      @handleError(XMLHttpRequest, textStatus, errorThrown)

    $.when(auditorRequest,managerRequest,developerRequest,orgUserRequest,orgManagerRequest).then success, failure

  handleError : (XMLHttpRequest, textStatus, errorThrown)->
    if(XMLHttpRequest.status ==403)
      bootbox.alert(XMLHttpRequest.responseJSON.description)