
backbone = require 'backbone'
_ = require 'underscore'
$ = require 'jquery'
spinner = require './Spinner'
require 'select2'
require 'bootstrap'
bootbox = require 'bootbox'
templateText = """<div class="container"><div class="row">
      <div class="col-sm-12 h3 border-bottom">Add User</div>
  </div>
      <form class="form-horizontal">

          <div class="form-group">

              <div class="row">
                  <div class="col-sm-1">&nbsp;</div>
                  <div class="col-sm-3 bold">User Id</div>
                  <div class="col-sm-2 bold">Identity Provider</div>
                  <div class="col-sm-3 bold">Password</div>
                  <div class="col-sm-3 bold">Verify</div>
              </div>
              <div class="row">
                  <div class="col-sm-1">&nbsp;</div>
                  <div class="col-sm-3"><input id="user-id" class="form-control user-id" type="text" /></div>
                  <div class="col-sm-2"><div class="identity-provider" id="identity-provider"></div></div>
                  <div class="col-sm-3"><input id="password" class="form-control password" type="password" disabled data-toggle="tooltip" title="Password and Verify must match."/></div>
                  <div class="col-sm-3"><input class="password2 form-control" type="password" disabled data-toggle="tooltip" title="Password and Verify must match."/></div>
              </div>
              <div class="row">
                  <div class="col-sm-12">&nbsp;</div>
              </div>
              <div class="row">
                  <div class="col-sm-1">&nbsp;</div>
                  <div class="col-sm-10 ">
                      <table class="table table-bordered table-striped">
                          <tr><th>Organization</th><th>Org Developer</th><th>Org Manager</th><th>Org Auditor</th></tr>
                          <tr>
                              <td><div class="org-select" id="org-select"></div></td>
                              <td><input class="org-user" type="checkbox" CHECKED disabled /></td>
                              <td><input class="org-manager" type="checkbox" /></td>
                              <td><input class="org-auditor" type="checkbox" /></td>
                          </tr>
                      </table>
                  </div>
              </div>

              <div class="row ">
                  <div class="col-sm-1">&nbsp;</div>
                  <div class="col-sm-10 space-roles"></div>
              </div>
              <div class="row">
                  <div class="col-sm-1">&nbsp;</div>
                  <div class="col-sm-10 right-justified"><button type="button" class="btn btn-primary create-user-button" disabled>Create User</button></div>
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
    @requestJson =
       userId : null
       aduser : true
       password : null
       org :
         guid     : null
         developer : true
         manager     : false
         auditor   : false
       identityProvider : "ldap"
       spaces : []
  events :
     "change .user-id " : "changeUserId"
     "change .password" : "changePassword"
     "change .password2" : "changePassword"
     "click  .create-user-button" : "addUser"




  render : ->
    $('.adduser_tab').tab('show');
    @$el.html template
    @$('[data-toggle="tooltip"]').tooltip()
    @$('.user-id').on "keyup", $.proxy(@changeUserId,@)
    @$('.password').on "keyup", $.proxy(@changePassword,@)
    @$('.password2').on "keyup", $.proxy(@changePassword,@)

    @$('.org-manager').on "change" , (e)=>
      @requestJson.org.manager = $(e.target).is(':checked')
      @setAdduserButtonState()
      true
    @$('.org-auditor').on "change" , (e)=>
      @requestJson.org.auditor = $(e.target).is(':checked')
      @setAdduserButtonState()
      true


    @orgSelect = @$('.org-select')
    @orgSelect.select2
      data : []
      placeholder : "Select Org"
      multiple : false
      allowClear : true

    @identityProviderSelect = @$(".identity-provider")
    @identityProviderSelect.select2
      data : []
      placeholder : "Select Identity"
      multiple : false
      allowClear : false

    spinner.blockUI()
    orgRequest = $.ajax
      url:"https://#{@host}/cf-users/cf-api/users/#{@userData.guid}/organizations"
    userIsOrgManagerRequest = $.ajax
      url : "https://#{@host}/cf-users/cf-api/users/#{@userData.guid}/managed_organizations"
    samlProvidersRequest = $.ajax
      url : "https://#{@host}/cf-users/cf-api/identityProviders/saml"

    success = (orgData,managedOrgData,samlProviders) =>

      @managedOrgs = {}
      for org in managedOrgData[0].resources
        @managedOrgs[org.metadata.guid] = true

      spinner.unblockUI()
      orgs = ( { text: org.entity.name, id:org.metadata.guid } for org in orgData[0].resources )
      orgs.sort (val1,val2) ->
        val1.text.toLowerCase().localeCompare(val2.text.toLowerCase())
      @orgMap = {}

      for org in orgData[0].resources
        @orgMap[org.metadata.guid] = org.entity.name
      @orgSelect.select2
        data : orgs
        placeholder : "Select Org"
        multiple : false
        allowClear : true

      identityProviders = [
        { text : "Active Directory", id:"ldap"}
        { text : "Cloud Foundry", id:"uaa"}
      ]
      for identityProvider in samlProviders[0]
        identityProviders.push { text : identityProvider, id: identityProvider }
      @identityProviderSelect.select2
        data : identityProviders
        placeholder : "Select Identity "
        multiple : false
        allowClear : false

      @identityProviderSelect.select2("val","ldap")
      @identityProviderSelect.change($.proxy( @changeAdUser,@))

    failure = (XMLHttpRequest, textStatus, errorThrown) =>
      spinner.unblockUI()
      @handleError(XMLHttpRequest, textStatus, errorThrown)

    $.when(orgRequest,userIsOrgManagerRequest,samlProvidersRequest).then success, failure

    @orgSelect.on 'change', (e) =>
      $.proxy(@selectOrg,@)(e)
  selectOrg :   (e) ->
    @$('.space-roles').html($("<div/>"))
    if(e.val)

      @orgGuid = e.val
      @requestJson.org.guid = e.val
      @$('.org-manager').prop("disabled",!@managedOrgs[@orgGuid])
      @$('.org-auditor').prop("disabled",!@managedOrgs[@orgGuid])
      @setAdduserButtonState()
      spinner.blockUI()
      spacesUrl= if(@managedOrgs[@orgGuid]) then  "https://#{@host}/cf-users/cf-api/organizations/#{@orgGuid}/spaces" else  "https://#{@host}/cf-users/cf-api/users/#{@userData.guid}/managed_spaces?q=organization_guid:#{@orgGuid}"
      $.ajax
        url: spacesUrl

        success : (data)=>
          spinner.unblockUI()
          spaceTable = $("<table class=\"table table-bordered table-striped\"><tr><th>Space</th><th>Space Developer</th><th>Space Manager</th><th>Space Auditor</th></tr></table>")
          spaceRequests = []
          @$('.space-roles').html(spaceTable)
          spaces = data.resources
          spaces.sort (val1,val2) ->
            val1.entity.name.toLowerCase().localeCompare(val2.entity.name.toLowerCase())
          for space in spaces
            do (space) =>
              row = $("<tr></tr>")
              row.append $("<td>#{space.entity.name}</td>")
              row.append $("<td><input class=\"space-developer\" type=\"checkbox\" /></td>")
              row.append $("<td><input class=\"space-manager\" type=\"checkbox\" /></td>")
              row.append  $("<td><input class=\"space-auditor\" type=\"checkbox\" /></td>")

              spaceTable.append(row)
              spaceRequest =
                guid :space.metadata.guid
                developer : false
                manager : false
                auditor: false
              spaceRequests.push spaceRequest
              spaceDeveloper = row.find('.space-developer')
              spaceDeveloper.on 'change', () =>
                spaceRequest.developer = spaceDeveloper.is(':checked')
                @setAdduserButtonState()
                true
              spaceManager = row.find('.space-manager')
              spaceManager.on 'change', () =>
                spaceRequest.manager = spaceManager.is(':checked')
                @setAdduserButtonState()
                true
              spaceAuditor = row.find('.space-auditor')
              spaceAuditor.on 'change', () =>
                spaceRequest.auditor = spaceAuditor.is(':checked')
                @setAdduserButtonState()
                true
          @requestJson.spaces = spaceRequests
  handleError : (XMLHttpRequest, textStatus, errorThrown)->
    spinner.unblockUI()
    if(XMLHttpRequest.status == 409)
      bootbox.alert("User \"#{@requestJson.userId}\" already exists.")
    else if(XMLHttpRequest.status == 403)
      bootbox.alert(XMLHttpRequest.responseJSON.description)
    else
      bootbox.alert("There was an error when adding user.\n\n" + XMLHttpRequest.responseText)



  addUser : () ->
    spinner.blockUI()
    $.ajax
      url: "https://#{@host}/cf-users/cf-api/users"
      method: "POST"
      contentType: "application/json"
      datatype : "json"
      data : JSON.stringify @requestJson
      success : (data)=>
        bootbox.alert("User #{@requestJson.userId} has been created.")
        Backbone.history.loadUrl()
      error : $.proxy(@handleError,@)
      complete: ()->
        spinner.unblockUI()

  changeAdUser: (e) ->
    identityProvider = @identityProviderSelect.val()

    @requestJson.identityProvider = identityProvider
    @$(".password").prop('disabled',identityProvider!="uaa")
    @$(".password2").prop('disabled',identityProvider!="uaa")
    @setAdduserButtonState()
    true

  changePassword : (e) ->

    password1 = @$('.password').val().trim()
    password2 = @$('.password2').val().trim()
    if(password1!=password2)
      @requestJson.password = ""
      @$('.password').parent().addClass("has-error")
      @$('.password2').parent().addClass("has-error")
      @requestJson.password=""
    else
      @$('.password').parent().removeClass("has-error")
      @$('.password2').parent().removeClass("has-error")
      @requestJson.password = @$(e.target).val()
    @setAdduserButtonState()

  changeUserId : (e) ->
    @requestJson.userId =  $(e.target).val()
    @setAdduserButtonState()

  getCheckedCounts : () ->
    @$('.space-manager:checked').length +
      @$('.space-auditor:checked').length +
      @$('.space-developer:checked').length +
      @$('.org-manager:checked').length +
      @$('.org-auditor:checked').length


  setAdduserButtonState: ->
    checkCounts = @getCheckedCounts()
    @$('.create-user-button').prop("disabled",!(@requestJson.userId&&(@requestJson.identityProvider!="uaa"||@requestJson.password)&&@requestJson.org.guid&&(checkCounts>0)))
