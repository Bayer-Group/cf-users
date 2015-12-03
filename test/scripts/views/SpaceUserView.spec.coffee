jsdom = require('jsdom').jsdom
chai = require('chai')
expect = chai.expect
chai.use(require('chai-string'));
sinon = require('sinon')


module.exports = describe 'SpaceUserView ', () ->

  SpaceUserView = undefined
  $ = undefined
  global.beforeEach ->
    if not global.document
      global.document = jsdom '<html><head></head><body></body></html>'
      global.window = document.parentWindow
      global.navigator = userAgent: 'Chrome'
    $ = require 'jquery'
    global.jQuery = $
    Backbone = require 'backbone'
    Backbone.$ = $
    SpaceUserView = require '../../../public/scripts/views/SpaceUserView'
    global.HTMLElement = $('<div/>')[0].constructor
    global.setTimeout = (fun,timeout)->
      console.log("settimeout #{new Error().stack}")
      fun
    global.window.setTimeout = global.setTimeout
    global.alert = ()->
      true
  global.afterEach ->
    $(element).html '' for element in ['head', 'body']
  it "renders properly", () ->
    view = new SpaceUserView
       host: "host"
       spaceGuid : "spaceGuid"
       userGuid : "userGuid"
       userName : "userName"
       isManager : false
       isAuditor : false
       isDeveloper : false
       userIsSpaceManager : true
    view.render()
    devChecked = view.$(".space-developer").is(":CHECKED")
    expect(devChecked).to.equal(false)
    managerChecked = view.$(".space-manager").is(":CHECKED")
    expect(managerChecked).to.equal(false);
    auditorChecked = view.$(".space-auditor").is(":CHECKED")
    expect(auditorChecked).to.equal(false);
    expect(view.$(".space-developer").is(":DISABLED")).to.equal(false)
    expect(view.$(".space-manager").is(":DISABLED")).to.equal(false)
    expect(view.$(".space-auditor").is(":DISABLED")).to.equal(false)


  it "renders spaceDeveloper as checked if space developer", () ->
    view = new SpaceUserView
      host: "host"
      spaceGuid : "spaceGuid"
      userGuid : "userGuid"
      userName : "userName"
      isManager : false
      isAuditor : false
      isDeveloper : true
      userIsSpaceManager : true
    view.render()
    expect(view.$(".space-developer").is(":CHECKED")).to.equal(true)
    expect(view.$(".space-developer").is(":DISABLED")).to.equal(false)

  it "renders spaceManager as checked if space manager", () ->
    view = new SpaceUserView
      host: "host"
      spaceGuid : "spaceGuid"
      userGuid : "userGuid"
      userName : "userName"
      isManager : true
      isAuditor : false
      isDeveloper : false
      userIsSpaceManager : true
    view.render()
    expect(view.$(".space-manager").is(":CHECKED")).to.equal(true)
    expect(view.$(".space-manager").is(":DISABLED")).to.equal(false)

  it "renders spaceAuditor as checked if space auditor", () ->
    view = new SpaceUserView
      host: "host"
      spaceGuid : "spaceGuid"
      userGuid : "userGuid"
      userName : "userName"
      isManager : false
      isAuditor : true
      isDeveloper : false
      userIsSpaceManager : true
    view.render()
    expect(view.$(".space-auditor").is(":CHECKED")).to.equal(true)
    expect(view.$(".space-auditor").is(":DISABLED")).to.equal(false)

  it "renders all checkboxes disabled if user is not space manager", () ->
    view = new SpaceUserView
      host: "host"
      spaceGuid : "spaceGuid"
      userGuid : "userGuid"
      userName : "userName"
      isManager : false
      isAuditor : false
      isDeveloper : false
      userIsSpaceManager : false
    view.render()
    expect(view.$(".space-manager").is(":DISABLED")).to.equal(true)
    expect(view.$(".space-developer").is(":DISABLED")).to.equal(true)
    expect(view.$(".space-auditor").is(":DISABLED")).to.equal(true)

  it "calls proper rest service when space-developer is checked", () ->
    ajaxFired = false;
    method = ""
    url = ""
    stub =  sinon.stub $,"ajax" , (req) ->
      ajaxFired=true
      url=req.url
      method = req.method
    view = new SpaceUserView
      host: "host"
      spaceGuid : "spaceGuid"
      userGuid : "userGuid"
      userName : "userName"
      isManager : false
      isAuditor : false
      isDeveloper : false
      userIsSpaceManager : true

    $('body').append(view.$el)
    view.render()
    expect(view.$('.space-developer').is(":DISABLED")).to.equal(false)
    view.$('.space-developer').click()
    expect(ajaxFired).to.equal(true)
    expect(url).to.equal("https://host/cf-users/cf-api/spaces/spaceGuid/developers/userGuid")
    expect(method).to.equal("PUT")
    view.$el.remove()
    stub.restore()

  it "calls proper rest service when space-developer is unchecked", () ->
    ajaxFired = false;
    method = ""
    url = ""
    stub =  sinon.stub $,"ajax" ,  (req) ->
      ajaxFired=true
      url=req.url
      method = req.method
    view = new SpaceUserView
      host: "host"
      spaceGuid : "spaceGuid"
      userGuid : "userGuid"
      userName : "userName"
      isManager : false
      isAuditor : false
      isDeveloper : true
      userIsSpaceManager : true

    $('body').append(view.$el)
    view.render()
    expect(view.$('.space-developer').is(":DISABLED")).to.equal(false)
    view.$('.space-developer').click()
    expect(ajaxFired).to.equal(true)
    expect(url).to.equal("https://host/cf-users/cf-api/spaces/spaceGuid/developers/userGuid")
    expect(method).to.equal("DELETE")
    view.$el.remove()
    stub.restore()


  it "calls proper rest service when space-manager is checked", () ->
    ajaxFired = false;
    method = ""
    url = ""
    stub =  sinon.stub $,"ajax" ,  (req) ->
      ajaxFired=true
      url=req.url
      method = req.method
    view = new SpaceUserView
      host: "host"
      spaceGuid : "spaceGuid"
      userGuid : "userGuid"
      userName : "userName"
      isManager : false
      isAuditor : false
      isDeveloper : false
      userIsSpaceManager : true

    $('body').append(view.$el)
    view.render()
    expect(view.$('.space-manager').is(":DISABLED")).to.equal(false)
    view.$('.space-manager').click()
    expect(ajaxFired).to.equal(true)
    expect(url).to.equal("https://host/cf-users/cf-api/spaces/spaceGuid/managers/userGuid")
    expect(method).to.equal("PUT")
    view.$el.remove()
    stub.restore()

  it "calls proper rest service when space-manager is unchecked", () ->
    ajaxFired = false;
    method = ""
    url = ""
    stub =  sinon.stub $,"ajax" , (req) ->
      ajaxFired=true
      url=req.url
      method = req.method
    view = new SpaceUserView
      host: "host"
      spaceGuid : "spaceGuid"
      userGuid : "userGuid"
      userName : "userName"
      isManager : true
      isAuditor : false
      isDeveloper : false
      userIsSpaceManager : true

    $('body').append(view.$el)
    view.render()
    expect(view.$('.space-manager').is(":DISABLED")).to.equal(false)
    view.$('.space-manager').click()
    expect(ajaxFired).to.equal(true)
    expect(url).to.equal("https://host/cf-users/cf-api/spaces/spaceGuid/managers/userGuid")
    expect(method).to.equal("DELETE")
    view.$el.remove()
    stub.restore()



  it "calls proper rest service when space-auditor is checked", () ->
    ajaxFired = false;
    method = ""
    url = ""
    stub =  sinon.stub $,"ajax" ,  (req) ->
      ajaxFired=true
      url=req.url
      method = req.method
    view = new SpaceUserView
      host: "host"
      spaceGuid : "spaceGuid"
      userGuid : "userGuid"
      userName : "userName"
      isManager : false
      isAuditor : false
      isDeveloper : false
      userIsSpaceManager : true

    $('body').append(view.$el)
    view.render()
    expect(view.$('.space-auditor').is(":DISABLED")).to.equal(false)
    view.$('.space-auditor').click()
    expect(ajaxFired).to.equal(true)
    expect(url).to.equal("https://host/cf-users/cf-api/spaces/spaceGuid/auditors/userGuid")
    expect(method).to.equal("PUT")
    view.$el.remove()
    stub.restore()

  it "calls proper rest service when space-auditor is unchecked", () ->
    ajaxFired = false;
    method = ""
    url = ""
    stub =  sinon.stub $,"ajax" ,  (req) ->
      ajaxFired=true
      url=req.url
      method = req.method
    view = new SpaceUserView
      host: "host"
      spaceGuid : "spaceGuid"
      userGuid : "userGuid"
      userName : "userName"
      isManager : false
      isAuditor : true
      isDeveloper : false
      userIsSpaceManager : true

    $('body').append(view.$el)
    view.render()
    expect(view.$('.space-auditor').is(":DISABLED")).to.equal(false)
    view.$('.space-auditor').click()
    expect(ajaxFired).to.equal(true)
    expect(url).to.equal("https://host/cf-users/cf-api/spaces/spaceGuid/auditors/userGuid")
    expect(method).to.equal("DELETE")
    view.$el.remove()
    stub.restore()
