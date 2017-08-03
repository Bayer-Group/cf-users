backbone = require 'backbone'
$ = require 'jquery'
require 'select2'
require 'bootstrap'

template = (options) ->
  {tab} = options
  {userName} = options
  active = 'class="active"'
  """
  <nav class="navbar navbar-default navbar-static-top" role="navigation">
      <div class="navbar-brand">CF Users</div>
      <div class="container-fluid">
          <ul class="nav navbar-nav nav-pills">
              <li #{ active if tab is 'roles'}><a href="roles"  data-toggle="tab" class="roles_tab">User Role Admin</a></li>
              <li #{ active if tab is 'edituser'}><a href="edituser"   data-toggle="tab"  class="user_roles_tab" >Edit User</a></li>
              <li #{ active if tab is 'adduser'}><a href="adduser"   data-toggle="tab"  class="adduser_tab" >Add User</a></li>
              <li #{ active if tab is 'changepassword'}><a href="changepassword"   data-toggle="tab"  class="changepassword_tab" >Change Password</a></li>
          </ul>
          <div class="collapse navbar-collapse">
              <ul class="nav navbar-nav navbar-right">
                  <li  class="dropdown">
                      <a  href="#" class="dropdown-toggle" data-toggle="dropdown" ><span class="user-name">#{userName}</span><span class="caret"></span></a>
                      <ul class="dropdown-menu">
                          <li role="presentation"><a role="menuitem" class="logout_button" tabindex="-1" href="#">Logout</a></li>
                      </ul>
                  </li>
              </ul>
          </div>
      </div>
  </nav>
  <div class="appcontainer" ></div>"""
module.exports = backbone.View.extend
  initialize : (options) ->
    @host = options.host
    @jso = options.jso
  render : () ->
    splitHref = window.location.href.split('/')
    @$el.html template({tab : splitHref[splitHref.length-1].split("?")[0], userName : @userData.user_name})
    @$('.nav-pills a').on 'click', (event)=>
      $target = $(event.target)
      @navigate($target.attr('href'))

  events :
    'click .logout_button' : 'logout'

  logout : () ->
    @jso.wipeTokens()
    window.location.replace("https://#{window.loginDomain}/logout.do?redirect=https://#{@host}/cf-users/roles")

  navigate : (url) ->
    Backbone.history.navigate("cf-users/"+url, true);

  navigateTab : (tab) ->
    @$(".active").removeClass("active")
    @$(".#{tab}").parent().addClass("active")
