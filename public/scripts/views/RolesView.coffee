backbone = require 'backbone'
_ = require 'underscore'
$ = require 'jquery'
require 'select2'
require 'bootstrap'
spinner = require './Spinner'
#OrgView = require './OrgView'
#SpaceView = require './SpaceView'
OrgView = require './OrgView'
SpaceView = require './SpaceView'
template = (options) ->
  """
  <div class="container">
      <div class="row">
          <div class="col-sm-12 h3 border-bottom">User Role Admin</div>
      </div>
      <div class="row">
          <div class="col-md-3">
              <form class="form-horizontal">
                  <div class="form-group">
                      <div class="col-sm-2 "><label for="org-select" class="control-label">Org:</label></div>
                      <div class="col-sm-10"><div class="org-select" id="org-select"></div></div></div>

                  <div class="form-group">
                      <label for="space-select" class="col-sm-2 control-label">Space:</label>
                      <div class="col-sm-10"><div class="space-select" id="space-select"></div></div>
                  </div>
              </form>
          </div>
          <div class="col-md-9 user-permissions"></div>
      </div>
  </div>
  """


module.exports = backbone.View.extend
  initialize: (options) ->
    @jso = options.jso
    @host = options.host
    @loginHost = options.loginHost
    @userData = options.userData
  render: ->
    $('.roles_tab').tab('show');
    @$el.html template
    @orgSelect = @$('.org-select')
    @orgSelect.select2
      data: []
      placeholder: "Select Org"
      multiple: false
      allowClear: true
    @spaceSelect = @$('.space-select')
    @spaceSelect.select2
      data: []
      placeholder: "Select Space"
      multiple: false
      allowClear: true

    spinner.blockUI()
    orgRequest = $.ajax
      url: "https://#{@host}/cf-users/cf-api/organizations"


    success = (orgData) =>
      orgs = ( {text: org.entity.name, id: org.metadata.guid} for org in orgData.resources )
      orgs.sort (val1, val2) ->
        val1.text.toLowerCase().localeCompare(val2.text.toLowerCase())
      @orgMap = {}

      for org in orgData.resources
        @orgMap[org.metadata.guid] = org.entity.name
      @orgSelect.select2
        data: orgs
        placeholder: "Select Org"
        multiple: false
        allowClear: true
      @spaceSelect.select2
        data: []
        placeholder: "Select Space"
        multiple: false
        allowClear: true
      spinner.unblockUI()
      @orgSelect.on 'change', (e) =>
        @$('.user-permissions').html($("<div/>"))
        @spaceSelect.select2("val", "")
        @spaceSelect.select2
          data: []
          placeholder: "Select Space"
          multiple: false
          allowClear: true
        if(e.val)
          spinner.blockUI()
          @spaceMap = {}
          @orgGuid = e.val
          orgView = new OrgView({
            host: @host,
            orgGuid: @orgGuid,
            orgName: @orgMap[@orgGuid],
            userName: @userData.user_name
          })
          @$('.user-permissions').html(orgView.$el)
          orgView.render()
          $.ajax
            url: "https://#{@host}/cf-users/cf-api/organizations/#{@orgGuid}/spaces"
            success: (data)=>

              spaces = ( {text: space.entity.name, id: space.metadata.guid} for space in data.resources )
              spaces.sort (val1, val2) ->
                val1.text.toLowerCase().localeCompare(val2.text.toLowerCase())
              for space in data.resources
                @spaceMap[space.metadata.guid] = space.entity.name
              @spaceSelect.select2
                data: spaces
                placeholder: "Select Space"
                multiple: false
                allowClear: true


      @spaceSelect.on 'change', (e) =>
        if(e.val)
          @spaceGuid = e.val
          spaceView = new SpaceView({
            host: @host,
            orgGuid: @orgGuid,
            orgName: @orgMap[@orgGuid],
            spaceGuid: @spaceGuid,
            spaceName: @spaceMap[@spaceGuid],
            userName: @userData.user_name
          })
          @$('.user-permissions').html(spaceView.$el)
          spaceView.render()
        else
          orgView = new OrgView({
            host: @host,
            orgGuid: @orgGuid,
            orgName: @orgMap[@orgGuid],
            userName: @userData.user_name
          })
          @$('.user-permissions').html(orgView.$el)
          orgView.render()
    error = (XMLHttpRequest, textStatus, errorThrown) ->
      alert("Status: " + textStatus);
      alert("Error: " + errorThrown)
    $.when(orgRequest).then success, error
    @$el


