_ = require 'underscore'
jsdom = require('jsdom').jsdom
chai = require('chai')
expect = chai.expect
chai.use(require('chai-string'));
sinon = require('sinon')

_.debounce = (f) ->
  (args...) ->
    f(args...)


module.exports = describe 'EditUserView ', () ->
  EditUserView = undefined
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

    global.HTMLElement = $('<div/>')[0].constructor
    global.setTimeout = (fun,timeout)->
      fun
    global.window.setTimeout = global.setTimeout

    global.promise = (fn)->
      result = null
      isSuccess = false
      fn (result)->
        isSuccess = true
        result = success
      ,(result)->
        result = fail
      then: (success,fail)->
        if(isSuccess)
          success(result)
        else
        fail(result)
    global.alert = ()->
      true
    require("select2")

    spinner = require("../../../public/scripts/views/Spinner")
    spinner.blockUI = ()->
      true
    spinner.unblockUI = ()->
      true
    EditUserView = require '../../../public/scripts/views/EditUserView'
  global.afterEach ->
    $(element).html '' for element in ['head', 'body']

  userRequest = null

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
    },
    users = {
    "total_results" : 0
    "total_pages" : 1
    "resources" : []
    },
    checkboxResponse = {
      "total_results" : 0
      "total_pages" : 1
      "resources" : []
    }

  )->
    sinon.stub $,"ajax" , (req) ->

      if(req.url.indexOf('https://host/cf-users/cf-api/users/userGuid/organizations')>-1)
        if( req.success)
          req.success(managedOrgs)
        else
          [ managedOrgs ]
      else if(req.url.indexOf("https://host/cf-users/cf-api/users/userGuid/managed_spaces")>-1)
        if(req.success)
          req.success(orgSpaces)
        else
          [ orgSpaces ]
      else if(req.url.indexOf("https://host/cf-users/cf-api/users?page=1")>-1)
        if(req.success)
          req.success(users)
        else
          [ users ]
      else if (req.url.indexOf("https://host/cf-users/cf-api/users/userGuid/managed_organizations")>-1)
          [
            "total_results" : 0
            "total_pages" : 1
            "resources" : []
          ]

      else if(req.method != "PUT" && req.method != "DELETE")
        if(req.success)
          req.success(checkboxResponse)
        else
          [ checkboxResponse ]
      else if(req.url=="https://host/cf-users/cf-api/organizations/orgGuid1/users/userGuid1" && req.method=="PUT" && req.success )
#        console.log(new Error('dummy').stack)
        userRequest = req
        req.success({"d":"dummy"})
      else
        userRequest = req





  it 'renders', () ->
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
    ,
      "total_results": 1
      "total_pages": 1
      "resources": [
        "metadata":
          "guid": "userGuid1"
        "entity":
          "name": "userName1"
      ,
        "metadata":
          "guid": "userGuid2"
        "entity":
          "name": "userName2"
      ]
    view = new EditUserView
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
   

  renderWithCheckboxes = (checked) ->
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
    ,
      "total_results": 1
      "total_pages": 1
      "resources": [
        "metadata":
          "guid": "userGuid1"
        "entity":
          "username": "userName1"
      ,
        "metadata":
          "guid": "userGuid2"
        "entity":
          "username": "userName2"
      ]
    ,
        if (checked)
          "total_results" : 4
          "total_pages" : 1
          "resources" : [
            "metadata":
              "guid": "spaceGuid1"
            "entity":
              "name": "spaceName1"
          ,
            "metadata":
              "guid": "spaceGuid2"
            "entity":
              "name": "spaceName2"
          ,
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
        else
          null

    view = new EditUserView
      host: "host"
      loginHost: "loginHost"
      userData :
        guid : "userGuid"
    $("body").append(view.$el)
    view.render()
    view.orgSelect.select2("val","orgGuid1")
    view.userSelect.select2("val","userGuid1")
    view.populateTables()
    view


  it 'renders spaces when org chosen checkboxes not checked', () ->

    view = renderWithCheckboxes(false)
    $spaceDeveloper = view.$('.space-developer')
    expect($spaceDeveloper.length).to.equal(2)
    $spaceManager = view.$('.space-manager')
    expect($spaceManager.length).to.equal(2)
    $spaceAuditor = view.$('.space-auditor')
    expect($spaceAuditor.length).to.equal(2)
    expect($('.organization-user').prop("checked")).to.equal(false)
    expect($('.organization-manager').prop("checked")).to.equal(false)
    expect($('.organization-auditor').prop("checked")).to.equal(false)
    expect($('.space-developer').prop("checked")).to.equal(false)
    expect($('.space-manager').prop("checked")).to.equal(false)
    expect($('.space-auditor').prop("checked")).to.equal(false)
    view.$el.remove()
    stub.restore()

  it 'renders spaces when org chosen checkboxes checked', () ->
    view = renderWithCheckboxes(true)
    $spaceDeveloper = view.$('.space-developer')
    expect($spaceDeveloper.length).to.equal(2)
    $spaceManager = view.$('.space-manager')
    expect($spaceManager.length).to.equal(2)
    $spaceAuditor = view.$('.space-auditor')
    expect($spaceAuditor.length).to.equal(2)
    expect($('.organization-user').prop("checked")).to.equal(true)
    expect($('.organization-manager').prop("checked")).to.equal(true)
    expect($('.organization-auditor').prop("checked")).to.equal(true)
    expect($('.space-developer').prop("checked")).to.equal(true)
    expect($('.space-manager').prop("checked")).to.equal(true)
    expect($('.space-auditor').prop("checked")).to.equal(true)
    view.$el.remove()
    stub.restore()

  it 'organization-user fires PUT event when checked', () ->
    view = renderWithCheckboxes(true)
    view.$('.organization-user').trigger('change')
    expect(userRequest.method).to.equal("PUT")
    expect(userRequest.url).to.equal("https://host/cf-users/cf-api/organizations/orgGuid1/users/userGuid1")
    view.$el.remove()
    stub.restore()

  it 'organization-user fires DELETE event when unchecked', () ->
    view = renderWithCheckboxes(false)
    view.$('.organization-user').trigger("change")
    expect(userRequest.method).to.equal("DELETE")
    expect(userRequest.url).to.equal("https://host/cf-users/cf-api/organizations/orgGuid1/users/userGuid1")
    view.$el.remove()
    stub.restore()

  it 'organization-manager fires PUT event when checked', () ->
    view = renderWithCheckboxes(true)
    view.$('.organization-manager').trigger("change")
    expect(userRequest.method).to.equal("PUT")
    expect(userRequest.url).to.equal("https://host/cf-users/cf-api/organizations/orgGuid1/managers/userGuid1")
    view.$el.remove()
    stub.restore()

  it 'organization-manager fires DELETE event when unchecked', () ->
    view = renderWithCheckboxes(false)
    view.$('.organization-manager').trigger("change")
#    console.log(JSON.stringify(userRequest,0,2))
    expect(userRequest.method).to.equal("DELETE")
    expect(userRequest.url).to.equal("https://host/cf-users/cf-api/organizations/orgGuid1/managers/userGuid1")
    view.$el.remove()
    stub.restore()

  it 'organization-mauditor fires PUT event when checked', () ->
    view = renderWithCheckboxes(true)
    view.$('.organization-auditor').trigger("change")
    expect(userRequest.method).to.equal("PUT")
    expect(userRequest.url).to.equal("https://host/cf-users/cf-api/organizations/orgGuid1/auditors/userGuid1")
    view.$el.remove()
    stub.restore()

  it 'organization-mauditor fires DELETE event when unchecked', () ->
    view = renderWithCheckboxes(false)
    view.$('.organization-auditor').trigger("change")
    expect(userRequest.method).to.equal("DELETE")
    expect(userRequest.url).to.equal("https://host/cf-users/cf-api/organizations/orgGuid1/auditors/userGuid1")
    view.$el.remove()
    stub.restore()

  it 'space-developer fires PUT event when checked', () ->
    view = renderWithCheckboxes(true)
    $(view.$('.space-developer')[0]).trigger("change")
    expect(userRequest.method).to.equal("PUT")
    expect(userRequest.url).to.equal("https://host/cf-users/cf-api/spaces/spaceGuid1/developers/userGuid1")
    view.$el.remove()
    stub.restore()

  it 'space-developer fires DELETE event when unchecked', () ->
    view = renderWithCheckboxes(false)
    $(view.$('.space-developer')[0]).trigger("change")
    expect(userRequest.method).to.equal("DELETE")
    expect(userRequest.url).to.equal("https://host/cf-users/cf-api/spaces/spaceGuid1/developers/userGuid1")
    view.$el.remove()
    stub.restore()

  it 'space-manager fires PUT event when checked', () ->
    view = renderWithCheckboxes(true)
    $(view.$('.space-manager')[0]).trigger("change")
    expect(userRequest.method).to.equal("PUT")
    expect(userRequest.url).to.equal("https://host/cf-users/cf-api/spaces/spaceGuid1/managers/userGuid1")
    view.$el.remove()
    stub.restore()

  it 'space-manager fires DELETE event when unchecked', () ->
    view = renderWithCheckboxes(false)
    $(view.$('.space-manager')[0]).trigger("change")
    expect(userRequest.method).to.equal("DELETE")
    expect(userRequest.url).to.equal("https://host/cf-users/cf-api/spaces/spaceGuid1/managers/userGuid1")
    view.$el.remove()
    stub.restore()

  it 'space-auditor fires PUT event when checked', () ->
    view = renderWithCheckboxes(true)
    $(view.$('.space-auditor')[0]).trigger("change")
    expect(userRequest.method).to.equal("PUT")
    expect(userRequest.url).to.equal("https://host/cf-users/cf-api/spaces/spaceGuid1/auditors/userGuid1")
    view.$el.remove()
    stub.restore()

  it 'space-auditor fires DELETE event when unchecked', () ->
    view = renderWithCheckboxes(false)
    $(view.$('.space-auditor')[0]).trigger("change")
    expect(userRequest.method).to.equal("DELETE")
    expect(userRequest.url).to.equal("https://host/cf-users/cf-api/spaces/spaceGuid1/auditors/userGuid1")
    view.$el.remove()
    stub.restore()
