jsdom = require('jsdom').jsdom
chai = require('chai')
expect = chai.expect
chai.use(require('chai-string'));
sinon = require('sinon')



module.exports = describe 'OrgUserView ', () ->
  OrgUserView = undefined
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
    OrgUserView = require '../../../public/scripts/views/OrgUserView'
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
    view = new OrgUserView
       host: "host"
       orgGuid : "orgGuid"
       userGuid : "userGuid"
       userName : "userName"
       isManager : false
       isAuditor : false
       isOrgUser : false
       userIsOrgManager : true
    view.render()
    devChecked = view.$(".org-user").is(":CHECKED")
    expect(devChecked).to.equal(false)
    managerChecked = view.$(".org-manager").is(":CHECKED")
    expect(managerChecked).to.equal(false);
    auditorChecked = view.$(".org-auditor").is(":CHECKED")
    expect(auditorChecked).to.equal(false);
    expect(view.$(".org-user").is(":DISABLED")).to.equal(false)
    expect(view.$(".org-manager").is(":DISABLED")).to.equal(false)
    expect(view.$(".org-auditor").is(":DISABLED")).to.equal(false)


  it "renders spaceDeveloper as checked if org developer", () ->
    view = new OrgUserView
      host: "host"
      orgGuid : "orgGuid"
      userGuid : "userGuid"
      userName : "userName"
      isManager : false
      isAuditor : false
      isOrgUser : true
      userIsOrgManager : true
    view.render()
    expect(view.$(".org-user").is(":CHECKED")).to.equal(true)
    expect(view.$(".org-user").is(":DISABLED")).to.equal(false)

  it "renders spaceManager as checked if org manager", () ->
    view = new OrgUserView
      host: "host"
      orgGuid : "orgGuid"
      userGuid : "userGuid"
      userName : "userName"
      isManager : true
      isAuditor : false
      isOrgUser : false
      userIsOrgManager : true
    view.render()
    expect(view.$(".org-manager").is(":CHECKED")).to.equal(true)
    expect(view.$(".org-manager").is(":DISABLED")).to.equal(false)

  it "renders spaceAuditor as checked if org auditor", () ->
    view = new OrgUserView
      host: "host"
      orgGuid : "orgGuid"
      userGuid : "userGuid"
      userName : "userName"
      isManager : false
      isAuditor : true
      isOrgUser : false
      userIsOrgManager : true
    view.render()
    expect(view.$(".org-auditor").is(":CHECKED")).to.equal(true)
    expect(view.$(".org-auditor").is(":DISABLED")).to.equal(false)

  it "renders all checkboxes disabled if user is not org manager", () ->
    view = new OrgUserView
      host: "host"
      orgGuid : "orgGuid"
      userGuid : "userGuid"
      userName : "userName"
      isManager : false
      isAuditor : false
      isOrgUser : false
      userIsOrgManager : false
    view.render()
    expect(view.$(".org-manager").is(":DISABLED")).to.equal(true)
    expect(view.$(".org-user").is(":DISABLED")).to.equal(true)
    expect(view.$(".org-auditor").is(":DISABLED")).to.equal(true)

  it "calls proper rest service when org-user is checked", () ->
    ajaxFired = false;
    method = ""
    url = ""
    stub =  sinon.stub $,"ajax" , (req) ->
      ajaxFired=true
      url=req.url
      method = req.method
    view = new OrgUserView
      host: "host"
      orgGuid : "orgGuid"
      userGuid : "userGuid"
      userName : "userName"
      isManager : false
      isAuditor : false
      isOrgUser : false
      userIsOrgManager : true

    $('body').append(view.$el)
    view.render()
    expect(view.$('.org-user').is(":DISABLED")).to.equal(false)
    view.$('.org-user').click()
    expect(ajaxFired).to.equal(true)
    expect(url).to.equal("https://host/cf-users/cf-api/organizations/orgGuid/users/userGuid")
    expect(method).to.equal("PUT")
    view.$el.remove()
    stub.restore()

  it "calls proper rest service when org-user is unchecked", () ->
    ajaxFired = false;
    method = ""
    url = ""
    stub =  sinon.stub $,"ajax" , (req) ->
      ajaxFired=true
      url=req.url
      method = req.method
    view = new OrgUserView
      host: "host"
      orgGuid : "orgGuid"
      userGuid : "userGuid"
      userName : "userName"
      isManager : false
      isAuditor : false
      isOrgUser : true
      userIsOrgManager : true

    $('body').append(view.$el)
    view.render()
    expect(view.$('.org-user').is(":DISABLED")).to.equal(false)
    view.$('.org-user').click()
    expect(ajaxFired).to.equal(true)
    expect(url).to.equal("https://host/cf-users/cf-api/organizations/orgGuid/users/userGuid")
    expect(method).to.equal("DELETE")
    view.$el.remove()
    stub.restore()


  it "calls proper rest service when org-manager is checked", () ->
    ajaxFired = false;
    method = ""
    url = ""
    stub =  sinon.stub $,"ajax" , (req) ->
      ajaxFired=true
      url=req.url
      method = req.method
    view = new OrgUserView
      host: "host"
      orgGuid : "orgGuid"
      userGuid : "userGuid"
      userName : "userName"
      isManager : false
      isAuditor : false
      isOrgUser : false
      userIsOrgManager : true

    $('body').append(view.$el)
    view.render()
    expect(view.$('.org-manager').is(":DISABLED")).to.equal(false)
    view.$('.org-manager').click()
    expect(ajaxFired).to.equal(true)
    expect(url).to.equal("https://host/cf-users/cf-api/organizations/orgGuid/managers/userGuid")
    expect(method).to.equal("PUT")
    view.$el.remove()
    stub.restore()

  it "calls proper rest service when org-manager is unchecked", () ->
    ajaxFired = false;
    method = ""
    url = ""
    stub =  sinon.stub $,"ajax" , (req) ->
      ajaxFired=true
      url=req.url
      method = req.method
    view = new OrgUserView
      host: "host"
      orgGuid : "orgGuid"
      userGuid : "userGuid"
      userName : "userName"
      isManager : true
      isAuditor : false
      isOrgUser : false
      userIsOrgManager : true

    $('body').append(view.$el)
    view.render()
    expect(view.$('.org-manager').is(":DISABLED")).to.equal(false)
    view.$('.org-manager').click()
    expect(ajaxFired).to.equal(true)
    expect(url).to.equal("https://host/cf-users/cf-api/organizations/orgGuid/managers/userGuid")
    expect(method).to.equal("DELETE")
    view.$el.remove()
    stub.restore()



  it "calls proper rest service when org-auditor is checked", () ->
    ajaxFired = false;
    method = ""
    url = ""
    stub =  sinon.stub $,"ajax" ,(req) ->
      ajaxFired=true
      url=req.url
      method = req.method
    view = new OrgUserView
      host: "host"
      orgGuid : "orgGuid"
      userGuid : "userGuid"
      userName : "userName"
      isManager : false
      isAuditor : false
      isOrgUser : false
      userIsOrgManager : true

    $('body').append(view.$el)
    view.render()
    expect(view.$('.org-auditor').is(":DISABLED")).to.equal(false)
    view.$('.org-auditor').click()
    expect(ajaxFired).to.equal(true)
    expect(url).to.equal("https://host/cf-users/cf-api/organizations/orgGuid/auditors/userGuid")
    expect(method).to.equal("PUT")
    view.$el.remove()
    stub.restore()

  it "calls proper rest service when org-auditor is unchecked", () ->
    ajaxFired = false;
    method = ""
    url = ""
    stub =  sinon.stub $,"ajax" ,(req) ->
      ajaxFired=true
      url=req.url
      method = req.method
    view = new OrgUserView
      host: "host"
      orgGuid : "orgGuid"
      userGuid : "userGuid"
      userName : "userName"
      isManager : false
      isAuditor : true
      isOrgUser : false
      userIsOrgManager : true

    $('body').append(view.$el)
    view.render()
    expect(view.$('.org-auditor').is(":DISABLED")).to.equal(false)
    view.$('.org-auditor').click()
    expect(ajaxFired).to.equal(true)
    expect(url).to.equal("https://host/cf-users/cf-api/organizations/orgGuid/auditors/userGuid")
    expect(method).to.equal("DELETE")
    view.$el.remove()
    stub.restore()
