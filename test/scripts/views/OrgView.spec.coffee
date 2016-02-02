_ = require 'underscore'
jsdom = require('jsdom').jsdom
chai = require('chai')
expect = chai.expect
chai.use(require('chai-string'));
sinon = require('sinon')



describe 'OrgView ', () ->

  $ = undefined
  OrgView = undefined
  global.beforeEach ->
    if not global.document
      global.document = jsdom '<html><head></head><body></body></html>'
      global.window = document.parentWindow
      global.navigator = userAgent: 'Chrome'
    $ = require 'jquery'
    global.jQuery = $
    Backbone = require 'backbone'
    Backbone.$ = $
    OrgView = require '../../../public/scripts/views/OrgView'
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
    ],
    users = [
      "total_results" : 0
      "total_pages" : 1
      "resources" : []
    ]
  )->
    sinon.stub $,"ajax" , (req) ->
      if(req.url=='https://host/cf-users/cf-api/organizations/orgGuid/auditors')
        auditors
      else if (req.url=='https://host/cf-users/cf-api/organizations/orgGuid/users')
        developers
      else if (req.url=='https://host/cf-users/cf-api/organizations/orgGuid/managers')
        orgManagers
      else if (req.url.indexOf('https://host/cf-api/cf-users/organizations/orgGuid/users')==0)
        if(req.url.indexOf('?')>-1)
          req.success(orgUsers[0]);
        else
          orgUsers
      else if (req.url.indexOf('https://host/cf-users/cf-api/users')==0)
        if(req.url.indexOf('?')>-1)
          req.success(users[0]);
        else
          users


  it 'renders one row for one user', () ->
    ajaxStub = setupAjaxSpy(null,null,null,null,null,[
      "total_results" : 1
      "total_pages" : 1
      "resources" : [
        "metadata" :
          "guid" : "userGuid1"
        "entity" :
          "username" : "user1"
      ]
    ])
    view = new OrgView
      host: "host"
      orgGuid: "orgGuid"
      spaceGuid : "spaceGuid"
      spaceName : "spaceName"
      orgName   : "orgName"
      userName  : "userName"

    view.render()
    expect(view.$('tr').length).to.equal(2);

    expect(view.isOrgManager).to.equal(false)
    ajaxStub.restore()

  it 'renders with matching Org manager', () ->
    ajaxStub = setupAjaxSpy null,null,null,[
        "total_results" : 1
        "total_pages" : 1
        "resources" : [
          "metadata" :
            "guid" : "userGuid"
          "entity" :
            "username" : "userName"
        ]
      ], null,
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
    view = new OrgView
      host: "host"
      orgGuid: "orgGuid"
      spaceGuid : "spaceGuid"
      spaceName : "spaceName"
      orgName   : "orgName"
      userName  : "userName"

    view.render()
    expect(view.isOrgManager).to.equal(true)
    ajaxStub.restore()
  it 'renders with matching Developer', () ->
    ajaxStub = setupAjaxSpy null,null,
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
    view = new OrgView
      host: "host"
      orgGuid: "orgGuid"
      spaceGuid : "spaceGuid"
      spaceName : "spaceName"
      orgName   : "orgName"
      userName  : "userName"

    view.render()
    expect(view.$('tr').length).to.equal(2);
    expect(view.$('.org-auditor:checked').length).to.equal(0);
    expect(view.$('.org-manager:checked').length).to.equal(0);
    expect(view.$('.org-user:checked').length).to.equal(1);
    ajaxStub.restore()

  it 'renders with matching Manager', () ->
    ajaxStub = setupAjaxSpy null,null,null,
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
    view = new OrgView
      host: "host"
      orgGuid: "orgGuid"
      spaceGuid : "spaceGuid"
      spaceName : "spaceName"
      orgName   : "orgName"
      userName  : "userName"

    view.render()
    expect(view.$('tr').length).to.equal(2);
    expect(view.$('.org-auditor:checked').length).to.equal(0);
    expect(view.$('.org-manager:checked').length).to.equal(1);
    expect(view.$('.org-user:checked').length).to.equal(0);
    ajaxStub.restore()
    
  it 'renders with matching Auditor', () ->
    ajaxStub = setupAjaxSpy [
        "total_results" : 1
        "total_pages" : 1
        "resources" : [
          "metadata" :
            "guid" : "userGuid1"
          "entity" :
            "username" : "user1"
        ]
      ],null,null,null,null,
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
    view = new OrgView
      host: "host"
      orgGuid: "orgGuid"
      spaceGuid : "spaceGuid"
      spaceName : "spaceName"
      orgName   : "orgName"
      userName  : "userName"

    view.render()
    expect(view.$('tr').length).to.equal(2);
    expect(view.$('.org-auditor:checked').length).to.equal(1);
    expect(view.$('.org-manager:checked').length).to.equal(0);
    expect(view.$('.org-user:checked').length).to.equal(0);
    ajaxStub.restore()

