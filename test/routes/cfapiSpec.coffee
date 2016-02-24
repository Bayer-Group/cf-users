chai = require('chai')
chai.use(require('chai-string'));
expect = chai.expect
sinon = require('sinon')
mock = require 'mock-require'
equal = require 'deep-equal'
Promise = require 'promise'


describe 'cfapi  ', ->
  requestjs = (options,callback)->

    if(options.url=="https://api.domain.com/v2/spaces?order-direction=asc&page=1&results-per-page=50")
      callback(null,{ "statusCode" : 200}, JSON.stringify
          total_results : 1
          total_pages  : 1
          resources : [
            metadata :
              guid : "space1Guid"
            entity :
              name : "space1"
              organization_guid : "org1Guid"
              space_quota_definition_guid : "spaceQuotaGuid"
              disk_quota : 1024
              memory : 2048
              space_guid : "space1Guid"
          ]
      )
    else if(options.url=="https://api.domain.com/v2/organizations?order-direction=asc&page=1&results-per-page=50")
      callback(null,{ "statusCode" : 200}, JSON.stringify
          total_results : 2
          total_pages  : 2
          resources : [
            metadata :
              guid : "org1Guid"
            entity :
              name : "org1"
          ]
      )
    else if(options.url=="https://api.domain.com/v2/organizations?order-direction=asc&page=2&results-per-page=50")
      callback(null,{ "statusCode" : 200}, JSON.stringify
          total_results : 2
          total_pages  : 2
          resources : [
            metadata :
              guid : "org2Guid"
            entity :
              name : "org2"
          ]
      )
    else if(options.url=="https://uaa.domain.com/userinfo")
      callback(null,{ "statusCode" : 200}, JSON.stringify
        user_id :"userGuid"
        user_name : "userName"
      )
    else if(options.url=="https://api.domain.com/v2/users?order-direction=asc&results-per-page=50&page=1")
      callback(null,{ "statusCode" : 200}, JSON.stringify
          total_results : 2
          total_pages  : 2
          resources : [
            metadata :
              guid : "user1Guid"
            entity :
              name : "user1"
          ]
      )
    else if(options.url=="https://api.domain.com/v2/users?order-direction=asc&results-per-page=50&page=2")
      callback(null,{ "statusCode" : 200}, JSON.stringify
          total_results : 2
          total_pages  : 2
          resources : [
            metadata :
              guid : "user2Guid"
            entity :
              name : "user2"
          ]
      )
    else if(options.url=="https://api.domain.com/v2/spaces/spaceGuid/manager?order-direction=asc&page=1&results-per-page=50")
      callback(null,{ "statusCode" : 200}, JSON.stringify
          total_results : 2
          total_pages  : 2
          resources : [
            metadata :
              guid : "mgr1Guid"
            entity :
              name : "mgr1"
          ]
      )
    else if(options.url=="https://api.domain.com/v2/spaces/spaceGuid/manager?order-direction=asc&page=2&results-per-page=50")
      callback(null,{ "statusCode" : 200}, JSON.stringify
          total_results : 2
          total_pages  : 2
          resources : [
            metadata :
              guid : "mgr2Guid"
            entity :
              name : "mgr2"
          ]
      )
    else if(options.method=="PUT"&& options.url=="https://api.domain.com/v2/spaces/spaceGuid/manager/userGuid")
      callback(null,{ "statusCode" : 201}, JSON.stringify
        result : "added"
      )
    else if(options.method=="DELETE" && options.url=="https://api.domain.com/v2/spaces/spaceGuid/manager/userGuid")
      callback(null,{ "statusCode" : 201}, JSON.stringify
          result : "deleted"
      )
    else if(options.method=="PUT"&& options.url=="https://api.domain.com/v2/spaces/space2Guid/developers/userGuid")
      callback(null,{ "statusCode" : 201}, JSON.stringify
          result : "added"
      )
    else if(options.method=="PUT"&& options.url=="https://api.domain.com/v2/spaces/space1Guid/managers/userGuid")
      callback(null,{ "statusCode" : 201}, JSON.stringify
          result : "added"
      )
    else if(options.method=="PUT"&& options.url=="https://api.domain.com/v2/spaces/space3Guid/auditors/userGuid")
      callback(null,{ "statusCode" : 201}, JSON.stringify
          result : "added"
      )
    else if(options.method=="PUT"&& options.url=="https://api.domain.com/v2/organizations/orgGuid/users/userGuid")
      callback(null,{ "statusCode" : 201}, JSON.stringify
          result : "added"
      )
    else if(options.method=="PUT"&& options.url=="https://api.domain.com/v2/organizations/orgGuid/managers/userGuid")
      callback(null,{ "statusCode" : 201}, JSON.stringify
          result : "added"
      )
    else if(options.method=="PUT"&& options.url=="https://api.domain.com/v2/organizations/orgGuid/auditors/userGuid")
      callback(null,{ "statusCode" : 201}, JSON.stringify
          result : "added"
      )
    else if(options.method=="POST"&& options.url=="https://uaa.domain.com/Users")
      ldapRequest =
        "schemas": ["urn:scim:schemas:core:1.0" ]
        "userName": "user@email.domain.com"
        "name":
           "familyName": "email.domain.com"
           "givenName": "user"
        "emails": [
          "value": "user@email.domain.com"
        ]
        "approvals": []
        "active": true
        "verified": true
        "origin": "ldap"
      uaaRequest =
        "schemas": [
          "urn:scim:schemas:core:1.0"
        ]
        "userName": "user"
        "name":
          "familyName": "user",
          "givenName": "user"
        "emails": [
          {
            "value": "user"
          }
        ],
        "approvals": [],
        "active": true,
        "verified": true,
        "origin": "uaa",
        "password": "thePassword"
      samlRequest =
        "schemas": [
          "urn:scim:schemas:core:1.0"
        ]
        "userName": "user@email.domain.com"
        "name":
          "familyName": "email.domain.com",
          "givenName": "user"
        "emails": [
          {
            "value": "user@email.domain.com"
          }
        ],
        "approvals": [],
        "active": true,
        "verified": true,
        "origin": "saml",
        "externalId" : "user@email.domain.com"

      if(equal(options.json,ldapRequest)||equal(options.json,uaaRequest)||equal(options.json,samlRequest))
        callback(null,{ "statusCode" : 201},
          id : "userGuid"
        )
      else
        console.log("failed to respond to request #{JSON.stringify(options,0,2)}")
    else if(options.method=="POST" && options.url=="https://api.domain.com/v2/users"&&options.json.guid=="userGuid")
      callback(null,{ "statusCode" : 201},
        id : "userGuid"
      )

    else if(options.method=="GET" && options.url=="https://api.domain.com/v2/users/userGuid/managed_spaces?q=organization_guid:orgGuid")
      callback( null,{"statusCode" : 200}, JSON.stringify
          total_results : 2
          total_pages  : 2
          resources : [
            metadata :
              guid : "user1Guid"
            entity :
              name : "user1"
          ]
      )
    else
      console.log("failed to respond to request #{JSON.stringify(options,0,2)}")


  mock('request',requestjs)
  adminOauth = require "../../routes/AdminOauth"
  cfapi = require("../../routes/cfapi")
  serviceBindings = require "../../routes/serviceBindings"
  serviceBindings["cloud_foundry_api-portal-admin-id"] = { b64 : "portal-admin-id-value"}
  serviceBindings["cloud_foundry_api-portal-admin-pw"] = { b64 : "portal-admin-pw-value"}
  serviceBindings["cloud_foundry_api-uaa-client-id"] = { b64 : "uaa-client-id-value"}
  serviceBindings["cloud_foundry_api-uaa-client-secret"] = { b64 : "uaa-client-secret-value"}
  serviceBindings["cloud_foundry_api-uaa-domain"] = { value:"uaa.domain.com"}
  serviceBindings["cloud_foundry_api-domain"] = { value:"api.domain.com"}
  serviceBindings["cloud_foundry_api-default-email-domain"] = { value: "email.domain.com"}
  serviceBindings["cloud_foundry_api-user-name-type"] = { value: "email"}

  refreshToken =  (method) ->
    method
      token:
        access_token : "tokenvalue"
  beforeEach ()->
    adminOauth.refreshToken = refreshToken

  it 'allOrganizations retrieves all organizations',(done)->
    res =
      json : (organizations) ->
        expect(organizations.resources.length).to.equal(2)
        expect(organizations.resources[0].entity.name).to.equal("org1")
        expect(organizations.resources[0].metadata.guid).to.equal("org1Guid")
        expect(organizations.resources[1].entity.name).to.equal("org2")
        expect(organizations.resources[1].metadata.guid).to.equal("org2Guid")
        done()
    cfapi.allOrganizations
      headers :
        authorization : "Bearer oauthtoken"
    ,res

  it 'userInfo retrieves currentUser Information', (done)->
    res =
      json : (userInfo) ->
        expect(userInfo.user_id).to.equal("userGuid")
        expect(userInfo.user_name).to.equal("userName")
        done()
    res.status = (status)->
      res.statusCode = status
      res
    cfapi.userInfo
      headers :
        authorization : "Bearer oauthtoken"
    ,res

  it 'allUsers retrieves all users',(done)->
    res =
      json : (users) ->
        expect(users.resources.length).to.equal(2)
        expect(users.resources[0].entity.name).to.equal("user1")
        expect(users.resources[0].metadata.guid).to.equal("user1Guid")
        expect(users.resources[1].entity.name).to.equal("user2")
        expect(users.resources[1].metadata.guid).to.equal("user2Guid")
        done()
    cfapi.allUsers
      headers :
        authorization : "Bearer oauthtoken"
    ,res


  it 'listCfRequest retrieves all stuff to list (very generic)',(done)->
    res =
      json : (users) ->
        expect(users.resources.length).to.equal(2)
        expect(users.resources[0].entity.name).to.equal("mgr1")
        expect(users.resources[0].metadata.guid).to.equal("mgr1Guid")
        expect(users.resources[1].entity.name).to.equal("mgr2")
        expect(users.resources[1].metadata.guid).to.equal("mgr2Guid")
        done()
    cfapi.listCfRequest
      headers :
        authorization : "Bearer oauthtoken"
      params :
        level : "spaces"
        levelGuid : "spaceGuid"
        associationType : "manager"
    ,res

  it 'putRole delegates properly'  ,(done)->
    res =
      json : (userInfo) ->
        expect(userInfo.result).to.equal("added")
        expect(res.statusCode).to.equal(201)
        done()
    res.status = (status)->
      res.statusCode = status
      res
    cfapi.putRole
      headers :
        authorization : "Bearer oauthtoken"
      params :
        level : "spaces"
        levelGuid : "spaceGuid"
        associationType : "manager"
        associationGuid : "userGuid"
    ,res

  it 'deleteRole delegates properly'  ,(done)->
    res =
      json : (userInfo) ->
        expect(userInfo.result).to.equal("deleted")
        expect(res.statusCode).to.equal(201)
        done()
    res.status = (status)->
      res.statusCode = status
      res
    cfapi.deleteRole
      headers :
        authorization : "Bearer oauthtoken"
      params :
        level : "spaces"
        levelGuid : "spaceGuid"
        associationType : "manager"
        associationGuid : "userGuid"
    ,res

  it 'create user creates correct requests'  ,(done)->
    res = {}
    res.send = (message) ->
      res.message = message
      expect(res.statusCode).to.equal(201)
      expect(res.message).to.equal("user created")
      done()
    res.status = (status)->

      res.statusCode = status
      res
    cfapi.createUser
      headers :
        authorization : "Bearer oauthtoken"
      body :
        userId : "user@domain.com"
        identityProvider : "ldap"

        org :
           guid : "orgGuid"
           manager : true
           auditor : true
        spaces : [
           guid : "space1Guid"
           manager : true
           developer : false
           auditor : false
        ,
          guid : "space2Guid"
          manager : false
          developer : true
          auditor : false
        ,
          guid : "space3Guid"
          manager : false
          developer : false
          auditor : true
        ]

    ,res

  it 'create user uaa usercreates correct requests'  ,(done)->
    res = {}
    res.send = (message) ->
      res.message = message
      expect(res.statusCode).to.equal(201)
      expect(res.message).to.equal("user created")
      done()
    res.status = (status)->
      res.statusCode = status
      res
    cfapi.createUser
      headers :
        authorization : "Bearer oauthtoken"
      body :
        userId : "user@domain.com"
        password : "thePassword"
        identityProvider : "uaa"
        org :
          guid : "orgGuid"
          manager : false
          auditor : true
        spaces : [
        ]

    ,res


  it 'create user saml usercreates correct requests'  ,(done)->
    res = {}
    res.send = (message) ->
      res.message = message
      expect(res.statusCode).to.equal(201)
      expect(res.message).to.equal("user created")
      done()
    res.status = (status)->
      res.statusCode = status
      res
    cfapi.createUser
      headers :
        authorization : "Bearer oauthtoken"
      body :
        userId : "user@domain.com"
        password : "thePassword"
        identityProvider : "saml"
        org :
          guid : "orgGuid"
          manager : false
          auditor : true
        spaces : [
        ]

    ,res