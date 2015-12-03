_ = require 'underscore'
jsdom = require('jsdom').jsdom
chai = require('chai')
expect = chai.expect
chai.use(require('chai-string'));
sinon = require('sinon')



module.exports = describe 'SpaceView ', () ->
  $ = undefined
  SpaceView = undefined
  global.beforeEach ->
    if not global.document
      global.document = jsdom '<html><head></head><body></body></html>'
      global.window = document.parentWindow
      global.navigator = userAgent: 'Chrome'
    $ = require 'jquery'
    global.jQuery = $
    Backbone = require 'backbone'
    Backbone.$ = $
    SpaceView = require '../../../public/scripts/views/SpaceView'
    global.HTMLElement = $('<div/>')[0].constructor
    global.setTimeout = (fun,timeout)->
      console.log("settimeout #{new Error().stack}")
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

  setupAjaxSpy = (auditors = [
      "total_results" : 0
      "total_pages" : 1
      "resources" : []
    ],
    spaceManagers =           [
      "total_results" : 0
      "total_pages" : 1
      "resources" : []
    ],
    developers =           [
      "total_results" : 0
      "total_pages" : 1
      "resources" : []
    ],
    orgManagers =           [
      "total_results" : 0
      "total_pages" : 1
      "resources" : []
    ],
    orgUsers =    [
      "total_results" : 0
      "total_pages" : 1
      "resources" : []
    ]
  )->
    sinon.stub $,"ajax" , (req) ->
      if(req.url=='https://host/cf-users/cf-api/spaces/spaceGuid/auditors')
        auditors

      else if (req.url=='https://host/cf-users/cf-api/spaces/spaceGuid/managers')
        spaceManagers
      else if (req.url=='https://host/cf-users/cf-api/spaces/spaceGuid/developers')
        developers
      else if (req.url=='https://host/cf-users/cf-api/organizations/orgGuid/managers')
        orgManagers
      else if (req.url.indexOf('https://host/cf-users/cf-api/organizations/orgGuid/users')==0)
        if(req.url.indexOf('?')>-1)
          req.success(orgUsers[0]);
        else
          orgUsers


  it 'renders one row for one user', () ->
    stub = setupAjaxSpy(null,null,null,null,[
      "total_results" : 1
      "total_pages" : 1
      "resources" : [
        "metadata" :
          "guid" : "userGuid1"
        "entity" :
          "username" : "user1"
      ]
    ])
    view = new SpaceView
      host: "host"
      orgGuid: "orgGuid"
      spaceGuid : "spaceGuid"
      spaceName : "spaceName"
      orgName   : "orgName"
      userName  : "userName"

    view.render()
    expect(view.$('table > tbody >tr').length).to.equal(2);
    expect(view.isSpaceManager).to.equal(false)
    expect(view.isOrgManager).to.equal(false);
    stub.restore()

  it 'renders with matching Org manager', () ->
    stub = setupAjaxSpy null,null,null,[
        "total_results" : 1
        "total_pages" : 1
        "resources" : [
          "metadata" :
            "guid" : "userGuid"
          "entity" :
            "username" : "userName"
        ]
      ],
      [
        "total_results" : 1
        "total_pages" : 1
        "resources" : [
          "metadata" :
            "guid" : "userGuid1"
          "entity" :
            "username" : "user1"
        ]
      ]
    view = new SpaceView
      host: "host"
      orgGuid: "orgGuid"
      spaceGuid : "spaceGuid"
      spaceName : "spaceName"
      orgName   : "orgName"
      userName  : "userName"

    view.render()
    expect(view.$('table > tbody >tr').length).to.equal(2);
    expect(view.isSpaceManager).to.equal(false)
    expect(view.isOrgManager).to.equal(true)
    stub.restore()

  it 'renders with matching Space manager', () ->
    stub = setupAjaxSpy null,[
        "total_results" : 1
        "total_pages" : 1
        "resources" : [
          "metadata" :
            "guid" : "userGuid"
          "entity" :
            "username" : "userName"
        ]
      ],null,null,
      [
        "total_results" : 1
        "total_pages" : 1
        "resources" : [
          "metadata" :
            "guid" : "userGuid1"
          "entity" :
            "username" : "user1"
        ]
      ]
    view = new SpaceView
      host: "host"
      orgGuid: "orgGuid"
      spaceGuid : "spaceGuid"
      spaceName : "spaceName"
      orgName   : "orgName"
      userName  : "userName"

    view.render()
    expect(view.$('table > tbody >tr').length).to.equal(2);
    expect(view.isSpaceManager).to.equal(true)
    expect(view.isOrgManager).to.equal(false)
    stub.restore()

  it 'renders with matching Developer', () ->
    stub = setupAjaxSpy null,null,
      [
        "total_results" : 1
        "total_pages" : 1
        "resources" : [
          "metadata" :
            "guid" : "userGuid1"
          "entity" :
            "username" : "user1"
        ]
      ],null,
      [
        "total_results" : 1
        "total_pages" : 1
        "resources" : [
          "metadata" :
            "guid" : "userGuid1"
          "entity" :
            "username" : "user1"
        ]
      ]
    view = new SpaceView
      host: "host"
      orgGuid: "orgGuid"
      spaceGuid : "spaceGuid"
      spaceName : "spaceName"
      orgName   : "orgName"
      userName  : "userName"

    view.render()
    expect(view.$('table > tbody >tr').length).to.equal(2);
    expect(view.$('.space-auditor:checked').length).to.equal(0);
    expect(view.$('.space-manager:checked').length).to.equal(0);
    expect(view.$('.space-developer:checked').length).to.equal(1);
    stub.restore()

  it 'renders with matching Manager', () ->
    stub = setupAjaxSpy null,
      [
        "total_results" : 1
        "total_pages" : 1
        "resources" : [
          "metadata" :
            "guid" : "userGuid1"
          "entity" :
            "username" : "user1"
        ]
      ],null,null,
      [
        "total_results" : 1
        "total_pages" : 1
        "resources" : [
          "metadata" :
            "guid" : "userGuid1"
          "entity" :
            "username" : "user1"
        ]
      ]
    view = new SpaceView
      host: "host"
      orgGuid: "orgGuid"
      spaceGuid : "spaceGuid"
      spaceName : "spaceName"
      orgName   : "orgName"
      userName  : "userName"

    view.render()
    expect(view.$('table > tbody >tr').length).to.equal(2);
    expect(view.$('.space-auditor:checked').length).to.equal(0);
    expect(view.$('.space-manager:checked').length).to.equal(1);
    expect(view.$('.space-developer:checked').length).to.equal(0);
    stub.restore()

  it 'renders with matching Auditor', () ->
    stub = setupAjaxSpy [
        "total_results" : 1
        "total_pages" : 1
        "resources" : [
          "metadata" :
            "guid" : "userGuid1"
          "entity" :
            "username" : "user1"
        ]
      ],null,null,null,
      [
        "total_results" : 1
        "total_pages" : 1
        "resources" : [
          "metadata" :
            "guid" : "userGuid1"
          "entity" :
            "username" : "user1"
        ]
      ]
    view = new SpaceView
      host: "host"
      orgGuid: "orgGuid"
      spaceGuid : "spaceGuid"
      spaceName : "spaceName"
      orgName   : "orgName"
      userName  : "userName"

    view.render()
    expect(view.$('table > tbody >tr').length).to.equal(2);
    expect(view.$('.space-auditor:checked').length).to.equal(1);
    expect(view.$('.space-manager:checked').length).to.equal(0);
    expect(view.$('.space-developer:checked').length).to.equal(0);
    stub.restore()

  it 'renders two rows for two users with paged results', () ->
    stub = setupAjaxSpy(null,null,null,null,[
      "total_results" : 2
      "total_pages" : 2
      "resources" : [
        "metadata" :
          "guid" : "userGuid1"
        "entity" :
          "username" : "user1"
      ]
    ])
    view = new SpaceView
      host: "host"
      orgGuid: "orgGuid"
      spaceGuid : "spaceGuid"
      spaceName : "spaceName"
      orgName   : "orgName"
      userName  : "userName"

    view.render()
    expect(view.$('table > tbody >tr').length).to.equal(3);
    expect(view.isSpaceManager).to.equal(false);
    expect(view.isOrgManager).to.equal(false);
    stub.restore()

