
backbone = require 'backbone'
_ = require 'underscore'
$ = require 'jquery'
require '../../../bower_components/growl/javascripts/jquery.growl'
require 'select2'
require 'bootstrap'
bootbox = require 'bootbox'
spinner = require './Spinner'
Promise = require 'promise'
templateText = """<div class="container"><div class="row">
      <div class="col-sm-12 h3 border-bottom">Edit User</div>
  </div>
      <form class="form-horizontal">

          <div class="form-group">

              <div class="row">
                  <div class="col-sm-1">&nbsp;</div>
                  <div class="col-sm-3 bold">User Id</div>
                  <div class="col-sm-6 bold">&nbsp;</div>
              </div>
              <div class="row">
                  <div class="col-sm-1">&nbsp;</div>
                  <div class="col-sm-3"><div  class="user-id" /> </div>
                  <div class="col-sm-6">&nbsp;</div>
              </div>
              <div class="row">
                  <div class="col-sm-12">&nbsp;</div>
              </div>
              <div class="row">
                  <div class="col-sm-1">&nbsp;</div>
                  <div class="col-sm-10 ">
                      <table class="table table-bordered table-striped">
                          <tr><th>Organization</th><th>Org Developer</th><th>Org Manager</th><th>Org Auditor</th></tr>
                          <tr class="org-row">
                              <td><div class="org-select" id="org-select"></div></td>
                              <td><input class="organization-user" type="checkbox"  /></td>
                              <td><input class="organization-manager" type="checkbox"  /></td>
                              <td><input class="organization-auditor" type="checkbox"  /></td>
                          </tr>
                      </table>
                  </div>
              </div>

              <div class="row ">
                  <div class="col-sm-1">&nbsp;</div>
                  <div class="col-sm-10 space-roles"></div>
              </div>
          </div>
      </form>

</div>"""
template = _.template(templateText)
module.exports = backbone.View.extend
  initialize : (options) ->
    @jso = options.jso
    @host = options.host
    @loginHost = options.loginHost
    @userData = options.userData
    @roleCount = 0;
  render : () ->
    @$el.html template
    userCurrentPage = 1
    users = []

    @userSelect = @$('.user-id').select2
           data : []
           placeholder : "Select user"
           multiple : false
           allowClear : true

    @userSelect.on 'change', (e) =>
      $.proxy(@populateTables,@)()


    userHandler = (userData) =>
      for user in userData.resources
        users.push { text: user.entity.username, id:user.metadata.guid }
      if(userData.total_pages>userCurrentPage)
        userCurrentPage++;
        $.ajax
          url:"https://#{@host}/cf-users/cf-api/users}"
          success: userHandler
          error : (XMLHttpRequest, textStatus, errorThrown)=>
            spinner.unblockUI()
      else
        users = users.filter (a) ->
          a.text
        users.sort (a,b) ->
          a.text.toLowerCase().localeCompare(b.text.toLowerCase())
        @userSelect.select2
          data : users
          placeholder : "Select User"
          multiple : false
          allowClear : true
        spinner.unblockUI()
    orgs = []
    @orgSelect = @$('.org-select')
    @orgSelect.select2
      data : []
      placeholder : "Select Organization"
      multiple : false
      allowClear : true

    orgHandler = (orgData) =>
      for org in orgData.resources
        orgs.push { text:org.entity.name, id: org.metadata.guid}
      orgs.sort (a,b) =>
        a.text.toLowerCase().localeCompare(b.text.toLowerCase())
      @orgSelect.select2
        data : orgs
        placeholder : "Select Organization"
        multiple : false
        allowClear : true

      orgGuids = ( org.id for org in orgs).join()

      userRequest = $.ajax
        url: "https://#{@host}/cf-users/cf-api/users?page=#{userCurrentPage}"
        success : userHandler
        error : (XMLHttpRequest, textStatus, errorThrown)=>
          spinner.unblockUI()


    spinner.blockUI()
    orgRequest =  $.ajax
      url: "https://#{@host}/cf-users/cf-api/users/#{@userData.guid}/organizations"
      success : orgHandler
      error : (XMLHttpRequest, textStatus, errorThrown)=>
        spinner.unblockUI()

    @orgSelect.on 'change', (e) =>
      $.proxy(@populateTables,@)()
  populateTables : (e) ->
    @selectedUserGuid = @userSelect.select2('val')
    @selectedOrgGuid = @orgSelect.select2('val')



    if(@selectedUserGuid && @selectedOrgGuid)
      @selectedOrgName = @orgSelect.select2('data').text
      spinner.blockUI()
      @roleCount = 0

      orgUserRequest = $.ajax
        url: "https://#{@host}/cf-users/cf-api/users/#{@selectedUserGuid}/organizations?q=user_guid:#{@selectedUserGuid}"
      orgManagerRequest = $.ajax
        url: "https://#{@host}/cf-users/cf-api/users/#{@selectedUserGuid}/organizations?q=manager_guid:#{@selectedUserGuid}"
      orgAuditorRequest = $.ajax
        url: "https://#{@host}/cf-users/cf-api/users/#{@selectedUserGuid}/organizations?q=auditor_guid:#{@selectedUserGuid}"

      managedSpacesRequest = $.ajax
        url : "https://#{@host}/cf-users/cf-api/users/#{@userData.guid}/managed_spaces?q=organization_guid:#{@selectedOrgGuid}"

      allSpacesRequest = $.ajax
        url : "https://#{@host}/cf-users/cf-api/organizations/#{@selectedOrgGuid}/spaces"

      userIsOrgManagerRequest = $.ajax
        url : "https://#{@host}/cf-users/cf-api/users/#{@userData.guid}/managed_organizations"

      spaceDeveloperRequest = $.ajax
        url : "https://#{@host}/cf-users/cf-api/users/#{@selectedUserGuid}/spaces?q=organization_guid:#{@selectedOrgGuid}"
      spaceManagerRequest = $.ajax
        url : "https://#{@host}/cf-users/cf-api/users/#{@selectedUserGuid}/managed_spaces?q=organization_guid:#{@selectedOrgGuid}"
      spaceAuditorRequest = $.ajax
        url : "https://#{@host}/cf-users/cf-api/users/#{@selectedUserGuid}/audited_spaces?q=organization_guid:#{@selectedOrgGuid}"

      success = (orgUserResponse,orgManagerResponse,orgAuditorResponse,managedSpacesResponse,allSpacesResponse,userIsOrgManagerResponse,spaceDeveloperResponse,spaceManagerResponse,spaceAuditorResponse) =>

        isOrgUser = (x[0] for x in orgUserResponse[0].resources when x.metadata.guid==@selectedOrgGuid).length!=0
        isOrgManager = (x[0] for x in orgManagerResponse[0].resources when x.metadata.guid==@selectedOrgGuid).length!=0
        isOrgAuditor= (x[0] for x in orgAuditorResponse[0].resources when x.metadata.guid==@selectedOrgGuid).length!=0

        if isOrgAuditor
          @roleCount++
        if isOrgManager
          @roleCount++

        spaceDevelopers = {}
        for spaceDeveloper in spaceDeveloperResponse[0].resources
          spaceDevelopers[spaceDeveloper.metadata.guid] = true
          @roleCount++
        spaceManagers = {}
        for spaceManager in spaceManagerResponse[0].resources
          spaceManagers[spaceManager.metadata.guid] = true
          @roleCount++
        spaceAuditors = {}
        for spaceAuditor in spaceAuditorResponse[0].resources
          spaceAuditors[spaceAuditor.metadata.guid] = true
          @roleCount++

        userIsOrgManager = ( ( org for org in userIsOrgManagerResponse[0].resources when org.metadata.guid==@selectedOrgGuid ).length>0)
        spaces = if (userIsOrgManager)
                   ({guid : space.metadata.guid,  name : space.entity.name , developer: spaceDevelopers[space.metadata.guid],manager: spaceManagers[space.metadata.guid],auditor: spaceAuditors[space.metadata.guid]} for space in allSpacesResponse[0].resources )
                 else
                   ({guid : space.metadata.guid,  name : space.entity.name , developer: spaceDevelopers[space.metadata.guid],manager: spaceManagers[space.metadata.guid],auditor: spaceAuditors[space.metadata.guid]} for space in managedSpacesResponse[0].resources )

        spaces.sort (a,b) ->
          a.name.toLowerCase().localeCompare(b.name.toLowerCase())
        @setChecked(@$('.organization-user'),isOrgUser)
        @setChecked(@$('.organization-manager'),isOrgManager)
        @setChecked(@$('.organization-auditor'),isOrgAuditor)
        @$('.organization-manager').prop('disabled',!(isOrgUser&&userIsOrgManager))
        @$('.organization-auditor').prop('disabled',!(isOrgUser&&userIsOrgManager))
        orgRow = @$('.org-row')

        @setupOrgUserCheckboxHandler(userIsOrgManager)
        @setupCheckboxHandler('organization',@selectedOrgName, @selectedOrgGuid,orgRow,'manager',isOrgUser&&userIsOrgManager,userIsOrgManager)
        @setupCheckboxHandler('organization',@selectedOrgName,@selectedOrgGuid,orgRow,'auditor',isOrgUser&&userIsOrgManager, userIsOrgManager)

        spaceTable = $("<table class=\"table table-bordered table-striped\"><tr><th>Space</th><th>Space Developer</th><th>Space Manager</th><th>Space Auditor</th></tr></table>")
        spaceRequests = []
        @$('.space-roles').html(spaceTable)
        for space in spaces
          do (space) =>
              row = $("<tr></tr>")
              row.append $("<td>#{space.name}</td>")
              row.append $("<td><input class=\"space-developer\" type=\"checkbox\" #{if space.developer then 'CHECKED' else ' ' } /></td>")
              row.append $("<td><input class=\"space-manager\" type=\"checkbox\" #{if space.manager then 'CHECKED' else ' ' }  /></td>")
              row.append  $("<td><input class=\"space-auditor\" type=\"checkbox\" #{if space.auditor then 'CHECKED' else ' ' }  /></td>")
              @setupCheckboxHandler('space',space.name, space.guid,row,'developer',isOrgUser,userIsOrgManager)
              @setupCheckboxHandler('space',space.name, space.guid,row,'manager',isOrgUser,userIsOrgManager)
              @setupCheckboxHandler('space',space.name, space.guid,row,'auditor',isOrgUser,userIsOrgManager)
              spaceTable.append(row)
        spinner.unblockUI()
      successProxy = $.proxy(success,@)
      failure = (XMLHttpRequest, textStatus, errorThrown) =>
        spinner.unblockUI()
      $.when(orgUserRequest,orgManagerRequest,orgAuditorRequest,managedSpacesRequest,allSpacesRequest,userIsOrgManagerRequest,spaceDeveloperRequest,spaceManagerRequest,spaceAuditorRequest).then successProxy, failure
    else
      clearCheck = (element) ->
        element.prop('checked',false)
#          element.unbind('change')
        element.attr('disabled',true)
      clearCheck(@$('.organization-user'))
      clearCheck(@$('.organization-manager'))
      clearCheck(@$('.organization-auditor'))
      @$('.space-roles>table').remove()

  setupOrgUserCheckboxHandler : (isUserOrgManager) ->
    typeNameCapital = @selectedOrgName.charAt(0).toUpperCase() + @selectedOrgName.slice(1);
    element = @$('.organization-user')
    element.attr('disabled',(@roleCount>0) || (!isUserOrgManager))
    element.unbind('change')
    element.on 'change', _.debounce (e) =>
      target = $(e.target)
      checked = target.is(':checked')
      $('.organization-manager').prop('disabled',!checked)
      $('.organization-auditor').prop('disabled',!checked)
      method = if(checked) then "PUT" else "DELETE"
      $.ajax
        url: "https://#{@host}/cf-users/cf-api/organizations/#{@selectedOrgGuid}/users/#{@selectedUserGuid}"
        method : method
        success: ()=>
            if(method == "PUT")
              $.growl.notice({ message : "#{typeNameCapital} developer role has been added."})
            else
              $.growl.notice({message : "#{typeNameCapital} developer role has been removed."})

        error:  (XMLHttpRequest, textStatus, errorThrown) =>
          $.growl.error({ message: "Organization developer role change has failed." })
          target.prop('checked',!checked)

      true
    ,
      300



  setupCheckboxHandler : (type,typeName,guid,row,role,isOrgUser, isUserOrgManager) ->
    typeNameCapital = typeName.charAt(0).toUpperCase() + typeName.slice(1);
    element = row.find(".#{type}-#{role}")
#      element.prop('disabled',(!isOrgUser) )

    element.unbind('change')
    element.on 'change', (e) =>
      isCurrentlyOrgUser = @$('.organization-user').is(":checked")

      target = $(e.target)
      checked = target.is(':checked')
      @roleCount += if (checked) then  1 else -1
      @$('.organization-user').attr('disabled',(@roleCount>0) || (!isUserOrgManager))
      method = if(checked) then "PUT" else "DELETE"
      orgPromise = if(!isCurrentlyOrgUser && @selectedOrgGuid && @selectedUserGuid )
          then :  (resolve,reject) =>
            $.ajax
              url: "https://#{@host}/cf-users/cf-api/organizations/#{@selectedOrgGuid}/users/#{@selectedUserGuid}"
              method : "PUT"
              success : (value)=>
                @$('.organization-user').prop('checked',true)
                resolve(true)
              error:(XMLHttpRequest, textStatus, errorThrown) =>
                $.growl.error({ message : "#{typeNameCapital} #{role} role change as failed."})
                reject()
      else
        then : (success,fail)->
          success()



      orgPromise.then ()=>
        $.ajax
          url: "https://#{@host}/cf-users/cf-api/#{type}s/#{guid}/#{role}s/#{@selectedUserGuid}"
          method : method
          success: $.proxy ()->
            @$('.organization-user').prop('checked',true)
            @$('.organization-manager').prop('disabled',!isUserOrgManager)
            @$('.organization-auditor').prop('disabled',!isUserOrgManager)
            if(method == "PUT")
              $.growl.notice({ message : "#{typeNameCapital} #{role} role has been added."})
            else
              $.growl.notice({message : "#{typeNameCapital} #{role} role has been removed."})
          ,
            @
          error: (XMLHttpRequest, textStatus, errorThrown) =>
            $.growl.error({ message : "#{typeNameCapital} #{role} role change as failed."})
            target.prop('checked',!checked)
            @roleCount += if (checked) then -1 else 1
            @$('.organization-user').attr('disabled',(@roleCount>0))
      , ()->
        console.log("edit user fail")



  setChecked : (element,checked) ->
    isDisabled = element.is(':disabled')
    element.prop('checked',checked)
    element.attr('disabled',isDisabled)

