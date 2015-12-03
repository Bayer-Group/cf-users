_ = require 'underscore'
jsdom = require('jsdom').jsdom
chai = require('chai')
expect = chai.expect
chai.use(require('chai-string'));
sinon = require('sinon')

_.debounce = (f) ->
  (args...) ->
    f(args...)

module.exports = describe 'AddUserView ', () ->
  AddUserView = undefined
  $ = undefined
  stub = undefined

  global.beforeEach ->
    if not global.document
      global.document = jsdom '<html><head></head><body></body></html>'
      global.window = document.parentWindow
      global.navigator = userAgent: 'Chrome'
    $ = require 'jquery'

    global.jQuery = $
    Backbone = require 'backbone'
    Backbone.$ = $
    AddUserView = require '../../../public/scripts/views/AddUserView'
    global.HTMLElement = $('<div/>')[0].constructor
    global.setTimeout = (fun,timeout)->
#      console.log("settimeout #{new Error().stack}")
      fun
    global.window.setTimeout = global.setTimeout
    global.alert = ()->
      true
    require("select2")

    spinner = require("../../../public/scripts/views/Spinner")
    spinner.blockUI = ()->
      true
    spinner.unblockUI = ()->
      true
  global.afterEach ->
    $(element).html '' for element in ['head', 'body']



  createUserRequestJson = null
  setupAjaxSpy = (
    managedOrgs = {
    "total_results": 0
    "total_pages": 1
    "resources": []
    },
    orgSpaces = {
    "total_results": 0
    "total_pages": 1
    "resources": []
    }
  )->
    sinon.stub $,"ajax" , (req) ->
      if(req.url=='https://host/cf-users/cf-api/users/userGuid/managed_organizations')
        [managedOrgs]
      else if(req.url=='https://host/cf-users/cf-api/users/userGuid/organizations')
        [managedOrgs]
      else if(req.url.indexOf("https://host/cf-users/cf-api/organizations/orgGuid1/spaces")>-1)
        req.success(orgSpaces)
      else if(req.url.indexOf("https://host/cf-users/cf-api/identityProviders/saml")>-1)
        [[]]

      else
        createUserRequestJson = req.data




  it 'renders', () ->
    stub = setupAjaxSpy({
      "total_results": 1
      "total_pages": 1
      "resources": [
        "metadata":
          "guid": "orgGuid1"
        "entity":
          "name": "orgName1"
      ,
        "metadata":
          "guid": "orgGuid2"
        "entity":
          "name": "orgName2"
      ]
    })

    view = new AddUserView
      host: "host"
      loginHost: "loginHost"
      userData :
        guid : "userGuid"
    $("body").append(view.$el)
    view.render()
    view.orgSelect.select2("val","orgGuid2")
    data = view.orgSelect.select2("data")
    expect(data.text).to.equal("orgName2")
    view.$el.remove()
    stub.restore()
    
  it 'renders spaces when org chosen', () ->

    stub = setupAjaxSpy
      "total_results": 1
      "total_pages": 1
      "resources": [
        "metadata":
          "guid": "orgGuid1"
        "entity":
          "name": "orgName1"
      ,
        "metadata":
          "guid": "orgGuid2"
        "entity":
          "name": "orgName2"
      ]
    ,
      "total_results": 1
      "total_pages": 1
      "resources": [
        "metadata":
          "guid": "spaceGuid1"
        "entity":
          "name": "spaceName1"
      ,
        "metadata":
          "guid": "spaceGuid2"
        "entity":
          "name": "spaceName2"
      ]

    view = new AddUserView
      host: "host"
      loginHost: "loginHost"
      userData :
        guid : "userGuid"
    $("body").append(view.$el)
    view.render()
    view.orgSelect.select2("val","orgGuid1")
    view.selectOrg({val : view.orgSelect.select2("val")})
    $spaceDeveloper = view.$('.space-developer')
    expect($spaceDeveloper.length).to.equal(2)
    $spaceManager = view.$('.space-manager')
    expect($spaceManager.length).to.equal(2)
    $spaceAuditor = view.$('.space-auditor')
    expect($spaceAuditor.length).to.equal(2)
    view.$el.remove()
    stub.restore()
    
  renderAndSelectOrg = () ->

    stub = setupAjaxSpy
      "total_results": 1
      "total_pages": 1
      "resources": [
        "metadata":
          "guid": "orgGuid1"
        "entity":
          "name": "orgName1"
      ,
        "metadata":
          "guid": "orgGuid2"
        "entity":
          "name": "orgName2"
      ]
    ,
      "total_results": 1
      "total_pages": 1
      "resources": [
        "metadata":
          "guid": "spaceGuid1"
        "entity":
          "name": "spaceName1"
      ,
        "metadata":
          "guid": "spaceGuid2"
        "entity":
          "name": "spaceName2"
      ]

    view = new AddUserView
      host: "host"
      loginHost: "loginHost"
      userData :
        guid : "userGuid"
    $("body").append(view.$el)
    view.render()
    view.orgSelect.select2("val","orgGuid1")
    view.selectOrg({val : view.orgSelect.select2("val")})
    view
  it 'populates request json correctly for space-developer', () ->
    view = renderAndSelectOrg()
    expect(view.requestJson.spaces[0].developer).to.equal(false)
    $spaceDeveloper = view.$('.space-developer')
    $($spaceDeveloper[0]).attr('checked',true)
    $($spaceDeveloper[0]).trigger("change",$spaceDeveloper[0])
    expect(view.requestJson.spaces[0].developer).to.equal(true)
    view.$('.create-user-button').prop('disabled',false)
    view.$('.create-user-button').click()
    expect(createUserRequestJson).to.equal(JSON.stringify(view.requestJson))
    view.$el.remove()
    stub.restore()
    
  it 'populates request json correctly for space-manager', () ->
    view = renderAndSelectOrg()
    expect(view.requestJson.spaces[0].manager).to.equal(false)
    $spaceManager = view.$('.space-manager')
    $($spaceManager[0]).attr('checked',true)
    $($spaceManager[0]).trigger("change",$spaceManager[0])
    expect(view.requestJson.spaces[0].manager).to.equal(true)
    view.$('.create-user-button').prop('disabled',false)
    view.$('.create-user-button').click()
    expect(createUserRequestJson).to.equal(JSON.stringify(view.requestJson))
    view.$el.remove()
    stub.restore()
    
  it 'populates request json correctly for space-auditor', () ->
    view = renderAndSelectOrg()
    expect(view.requestJson.spaces[0].auditor).to.equal(false)
    $spaceAuditor = view.$('.space-auditor')
    $($spaceAuditor[0]).attr('checked',true)
    $($spaceAuditor[0]).trigger("change",$spaceAuditor[0])
    expect(view.requestJson.spaces[0].auditor).to.equal(true)
    view.$('.create-user-button').prop('disabled',false)
    view.$('.create-user-button').click()
    expect(createUserRequestJson).to.equal(JSON.stringify(view.requestJson))
    view.$el.remove()
    stub.restore()

  it 'populates request json correctly for org-auditor', () ->
    view = renderAndSelectOrg()
    expect(view.requestJson.org.auditor).to.equal(false)
    $orgAuditor = view.$('.org-auditor')
    $($orgAuditor[0]).attr('checked',true)
    $($orgAuditor[0]).trigger("change",$orgAuditor[0])
    expect(view.requestJson.org.auditor).to.equal(true)
    view.$('.create-user-button').prop('disabled',false)
    view.$('.create-user-button').click()
    expect(createUserRequestJson).to.equal(JSON.stringify(view.requestJson))
    view.$el.remove()
    stub.restore()

  it 'populates request json correctly for org-manager', () ->
    view = renderAndSelectOrg()
    expect(view.requestJson.org.manager).to.equal(false)
    $orgManager = view.$('.org-manager')
    $($orgManager[0]).attr('checked',true)
    $($orgManager[0]).trigger("change",$orgManager[0])
    expect(view.requestJson.org.manager).to.equal(true)
    view.$('.create-user-button').prop('disabled',false)
    view.$('.create-user-button').click()
    expect(createUserRequestJson).to.equal(JSON.stringify(view.requestJson))
    view.$el.remove()
    stub.restore()

  it 'populates request json correctly for org-user', () ->
    view = renderAndSelectOrg()

    $orgDeveloper = view.$('.org-user')
    $($orgDeveloper[0]).attr('checked',true)
    $($orgDeveloper[0]).trigger("change",$orgDeveloper[0])
    expect(view.requestJson.org.developer).to.equal(true)
    view.$('.create-user-button').prop('disabled',false)
    view.$('.create-user-button').click()
    expect(createUserRequestJson).to.equal(JSON.stringify(view.requestJson))
    view.$el.remove()
    stub.restore()

  it 'populates request json correctly in response to events', () ->
    view = renderAndSelectOrg()
    expect(view.requestJson.spaces[0].developer).to.equal(false)
    $spaceDeveloper = view.$('.space-developer')
    $($spaceDeveloper[0]).attr('checked',true)
    $($spaceDeveloper[0]).trigger("change",$spaceDeveloper[0])
    expect(view.requestJson.spaces[0].developer).to.equal(true)
    expect(view.requestJson.spaces[0].manager).to.equal(false)
    $spaceManager = view.$('.space-manager')
    $($spaceManager[0]).attr('checked',true)
    $($spaceManager[0]).trigger("change",$spaceManager[0])
    expect(view.requestJson.spaces[0].manager).to.equal(true)
    expect(view.requestJson.spaces[0].auditor).to.equal(false)
    $spaceAuditor = view.$('.space-auditor')
    $($spaceAuditor[0]).attr('checked',true)
    $($spaceAuditor[0]).trigger("change",$spaceAuditor[0])
    expect(view.requestJson.spaces[0].auditor).to.equal(true)

    expect(view.requestJson.org.developer).to.equal(true)

    expect(view.requestJson.org.manager).to.equal(false)
    $orgManager = view.$('.org-manager')
    $orgManager.attr('checked',true)
    $orgManager.trigger("change",$orgManager[0])
    expect(view.requestJson.org.manager).to.equal(true)
    expect(view.requestJson.org.auditor).to.equal(false)
    $orgAuditor = view.$('.org-auditor')
    $orgAuditor.attr('checked',true)
    $orgAuditor.trigger("change",$orgAuditor[0])
    expect(view.requestJson.org.auditor).to.equal(true)
    $userId = view.$('.user-id')
    $userId.val('userId')
    $userId.trigger('change')
    expect(view.requestJson.userId).to.equal("userId")

    expect(view.requestJson.identityProvider).to.equal("ldap")
    $identityProvider = view.identityProviderSelect
    expect($identityProvider.val()).to.equal("ldap")
    $identityProvider.val('uaa')
    $identityProvider.trigger('change',$identityProvider[0])
    expect($identityProvider.val()).to.equal("uaa")
    expect(view.requestJson.identityProvider).to.equal("uaa")
    $identityProvider.val('saml')
    $identityProvider.trigger('change',$identityProvider[0])
    expect(view.requestJson.identityProvider).to.equal("saml")
    $identityProvider.val('uaa').trigger("change")

    $userId = view.$('.password')
    $userId.val('userPassword')
    $userId.trigger('change')
    expect(view.requestJson.password).to.equal("")
    expect($('.create-user-button').prop('disabled')).to.equal(true)
    $userId2 = view.$('.password2')
    $userId2.val('userPassword')
    $userId2.trigger('change')
    expect(view.requestJson.password).to.equal("userPassword")
    expect($('.create-user-button').prop('disabled')).to.equal(false)
    $('.create-user-button').click()
    expect(createUserRequestJson).to.equal(JSON.stringify(view.requestJson))
    view.$el.remove()
    stub.restore()


