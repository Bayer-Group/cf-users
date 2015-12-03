$ = require 'jquery'
backbone = require 'backbone'
EmptyView = require './views/EmptyView'
ContainerView = require './views/ContainerView'
RolesView = require './views/RolesView'
EditUserView = require './views/EditUserView'
AddUserView = require './views/AddUserView'
module.exports =  backbone.Router.extend
  initialize : (options) ->
    @options = options
    @containerView = new ContainerView(options);
    $('body').html(@containerView.$el);

    userRequest = $.ajax
      url:"https://#{@options.host}/cf-users/cf-api/userinfo"

    success = (userData) =>
      userData.guid = userData.user_id
      @containerView.userData = userData
      @userData = userData;
      @containerView.render();
      backbone.history.start({pushState: true});
    error =  (XMLHttpRequest, textStatus, errorThrown) ->
      alert("Status: " + textStatus); alert("Error: " + errorThrown)
    $.when(userRequest).then success, error


  routes:
    "cf-users/roles" : "roles"
    "cf-users/adduser" : "adduser"
    "cf-users/edituser" : "edituser"

  roles : () ->
    if(@view)
      @view.remove()
    @options.userData = @userData;
    @view = new RolesView(@options);
    @containerView.$('.appcontainer').html(@view.$el);
    @view.render();

  adduser: () ->
    if(@view)
      @view.remove()
    @options.userData = @userData;
    @view = new AddUserView(@options);
    @containerView.$('.appcontainer').html(@view.$el);
    @view.render();

  edituser: () ->
    if(@view)
      @view.remove()
    @options.userData = @userData;
    @view = new EditUserView(@options);
    @containerView.$('.appcontainer').html(@view.$el);
    @view.render();

