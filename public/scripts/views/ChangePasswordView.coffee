
backbone = require 'backbone'
_ = require 'underscore'
$ = require 'jquery'
spinner = require './Spinner'
require 'select2'
require 'bootstrap'
bootbox = require 'bootbox'
templateText = """<div class="container"><div class="row">
      <div class="col-sm-12 h3 border-bottom">Change Password</div>
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
                  <div class="col-sm-3 bold">Old Password</div>
                  <div class="col-sm-3 bold">New Password</div>
                  <div class="col-sm-3 bold">Confirm New Password</div>
              </div>
              <div class="row">
                  <div class="col-sm-1">&nbsp;</div>
                  <div class="col-sm-3"><input id="oldpassword" class="form-control oldpassword" type="password" data-toggle="tooltip title="Current password for user."/></div>
                  <div class="col-sm-3"><input id="password" class="form-control password" type="password" data-toggle="tooltip" title="New Passwords must match."/></div>
		  <div class="col-sm-3"><input id="password2" class="form-control password2" type="password" data-toggle="tooltip" title="New Passwords must match."/></div>
              </div>
	      <div class="row">
                  <div class="col-sm-12">&nbsp;</div>
              </div>
              <div class="row">
                  <div class="col-sm-1">&nbsp;</div>
                  <div class="col-sm-10 right-justified"><button type="button" class="btn btn-primary update-pass-button" disabled>Change Password</button></div>
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
       newpassword : null
       oldpassword : null
  events :
     "change .user-id " : "changeUserId"
     "change .password" : "verifyPassword"
     "change .password2" : "verifyPassword"
     "click  .update-pass-button" : "changePassword"

  render : ->
    $('.passwordreset_tab').tab('show');
    @$el.html template
    @$('[data-toggle="tooltip"]').tooltip()
    @$('.user-id').on "keyup", $.proxy(@changeUserId,@)
    @$('.oldpassword').on "keyup", $.proxy(@setOldPassword,@)
    @$('.password').on "keyup", $.proxy(@verifyPassword,@)
    @$('.password2').on "keyup", $.proxy(@verifyPassword,@)
    
    userCurrentPage =1
    users = []

    @userSelect = @$('.user-id').select2
           data : []
           placeholder : "Select user"
           multiple : false
           allowClear : true
   
    @selectedUserGuid = @userSelect.select2('val')
 
    userHandler = (userData) =>
      for user in userData.resources
        users.push { text: user.userName, id:user.id }
      if(userData.total_pages>userCurrentPage)
        userCurrentPage++;
        $.ajax
          url:"https://#{@host}/cf-users/cf-api/uaausers}"
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

    spinner.blockUI()
    userRequest = $.ajax
        url: "https://#{@host}/cf-users/cf-api/uaausers?page=#{userCurrentPage}"
        success : userHandler
        error : (XMLHttpRequest, textStatus, errorThrown)=>
          spinner.unblockUI()
 
  handleError : (XMLHttpRequest, textStatus, errorThrown)->
    spinner.unblockUI()
    if(XMLHttpRequest.status == 409)
      bootbox.alert("User \"#{@requestJson.userId}\" already exists.")
    else if(XMLHttpRequest.status == 403)
      bootbox.alert(XMLHttpRequest.responseJSON.description)
    else
      bootbox.alert("There was an error changing the password.\n\n" + XMLHttpRequest.responseText)

  changePassword : () ->
    spinner.blockUI()
    $.ajax
      url: "https://#{@host}/cf-users/cf-api/password"
      method: "POST"
      contentType: "application/json"
      datatype : "json"
      data : JSON.stringify @requestJson
      success : (data)=>
        bootbox.alert("Password for #{@requestJson.userId} #{@selectedUserGuid} has been changed.")
        Backbone.history.loadUrl()
      error : $.proxy(@handleError,@)
      complete: ()->
        spinner.unblockUI()

  verifyPassword : (e) ->

    password1 = @$('.password').val().trim()
    password2 = @$('.password2').val().trim()
    if(password1!=password2)
      @requestJson.newpassword = ""
      @$('.password').parent().addClass("has-error")
      @$('.password2').parent().addClass("has-error")
    else
      @$('.password').parent().removeClass("has-error")
      @$('.password2').parent().removeClass("has-error")
      @requestJson.newpassword = @$('.password').val()
    @setChangepassButtonState()

  changeUserId : (e) ->
    @requestJson.userId =  $(e.target).val()
    @setChangepassButtonState()
 
  setOldPassword : (e) ->
    @requestJson.oldpassword = @$('.oldpassword').val()

  setChangepassButtonState: ->
    @$('.update-pass-button').prop("disabled",!(@requestJson.userId&&@requestJson.newpassword&&@requestJson.oldpassword))
