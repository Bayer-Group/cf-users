Promise = require 'promise'
adminOauth = require "./AdminOauth"
services = require "./serviceBindings"
requestjs = require 'request'


adminOauth.initOauth2()
cfapi = {}

cfapi.allOrganizations = (req,res) ->
  fetchAllOrganizations(req.headers['authorization'],[],1).then (orgs)=>
    res.json
      resources: orgs
    resolve(orgs)
  , (error)->
    res.status(500).send(error)
    reject(error)

cfapi.listUserAssociation = (req,res)->
  fetchUser(req,res).then (userInfo)->
    adminOauth.refreshToken (token) ->
      fetchListCfRequest("Bearer #{token.token.access_token}",[], "users",req.params.userGuid, req.params.associationType, req.query?.q, 1).then (values)=>
        res.json
          total_pages: 1
          resources: values
      ,(error)->
        res.sendStatus(500).send(error)
        reject(error)
  , (error) ->
    console.log("Unauthenticated user attempt to call listUserAccociation")

cfapi.listCfRequest = (req,res)->
  fetchListCfRequest(req.headers['authorization'],[], req.params.level,req.params.levelGuid, req.params.associationType, req.query?.q, 1).then (values)=>
    res.json
      total_pages: 1
      resources: values
  ,(error)->
    res.sendStatus(500).send(error)
    reject(error)

cfapi.userInfo = (req,res)->
  fetchUser(req,res).then (userInfo)->
    res.status(200).json userInfo
  , (error)->
    res.status(500).send(error)


fetchUser = (req,res)->
  new Promise (resolve,reject)->
    options =
      url: "https://#{services["cloud_foundry_api-uaa-domain"].value}/userinfo"
      headers: {'Authorization': req.headers['authorization']}
    requestjs options, (error,response,body) ->
      if(!error && response.statusCode==200)
        userInfo=JSON.parse(body)
        resolve(userInfo)
      else
        reject(error)

cfapi.allUsers = (req,res) ->
  fetchUser(req,res).then (userinfo)->
    adminOauth.refreshToken (token) ->
      fetchAllUsers(token,[],  1).then (values)=>
        res.json
          total_pages : 1
          resources: values
      ,(error)->
        res.sendStatus(500).send(error)
        reject(error)
  , (error) ->
    console.log("Unauthenticated user attempt to fetch all users")

cfapi.samlIdentityProviders = (req,res) ->
  fetchUser(req,res).then (userinfo)->
    if(services["cloud_foundry_api-saml-provider"]?.value)
      res.status(200).send [ services["cloud_foundry_api-saml-provider"]?.value ]
    else
      res.status(200).send [  ]
  , (error) ->
    res.status(401).send("Unauthenticated user attempt to fetch saml identity providers")
    console.log("Unauthenticated user attempt to fetch saml identity providers")


doRole = (method,token,level,levelGuid,associationType,associationGuid)->
  new Promise (resolve,reject)->
    options =
      method: method
      url: "https://#{services["cloud_foundry_api-domain"].value}/v2/#{level}/#{levelGuid}/#{associationType}/#{associationGuid}"
      headers: {'Authorization': token}
    requestjs options, (error,response,body) ->
      if((!error)&&(response.statusCode == 201))
        resolve
          status : response.statusCode
          body : JSON.parse(body)
      else if((!error)&& (response.statusCode == 204))
        resolve
          status : response.statusCode
      else if(!error)
        reject
          status : 500
          body: response
      else
        reject
          status : 500
          body : error

cfapi.putOrgUser = (req,res)->
  #first check if space manager
  authHeader = req.headers['authorization']
  fetchUser(req,res).then (userData)->
    adminOauth.refreshToken (token) ->
      options =
        method: "GET"
        url: "https://#{services["cloud_foundry_api-domain"].value}/v2/users/#{userData.user_id}/managed_spaces?q=organization_guid:#{req.params.levelGuid}"
        headers : {'Authorization' : "Bearer #{token.token.access_token}"}
      requestjs options, (error,response,body) ->
        responseBody = JSON.parse(body)
        if(!error && response.statusCode == 200 && responseBody["total_results"] > 0)
           authHeader = "Bearer #{token.token.access_token}"

        doRole('PUT',authHeader,"organizations",req.params.levelGuid,"users",req.params.associationGuid).then (response)->
          res.status(response.status).json(response.body)
        , (response)->
          res.status(response.status).send(response.body)
  , ()->
    res.status(403).send("Verboten")

cfapi.putRole = (req,res)->
  doRole('PUT',req.headers['authorization'],req.params.level,req.params.levelGuid,req.params.associationType,req.params.associationGuid).then (response)->
    res.status(response.status).json(response.body)
  , (response)->
    res.status(response.status).send(response.body)

cfapi.deleteRole = (req,res)->
  doRole('DELETE',req.headers['authorization'],req.params.level,req.params.levelGuid,req.params.associationType,req.params.associationGuid).then (response)->
    res.status(response.status).json(response.body)
  , (response)->
    res.status(response.status).send(response.body)

doPut = (url,token,form)->
  doRequest("PUT",url,token,form)

doPost = (url,token,form)->
  doRequest("POST",url,token,form)

doRequest = (method,url,token,form) ->
  new Promise (resolve,reject) ->
    options =
      method : method
      url: url
      headers : {'Authorization': "Bearer " + token.token.access_token}
      json : form
    try
      requestjs options, (error,response,body) ->
        if(!error && response.statusCode == 201)
          resolve
            status : response.statusCode
            body : body
        else if(!error )
          reject
            status : response.statusCode
            body: if(body) then body else "failed"
        else
          reject
            status : 500
            body : error
    catch error
      console.log("error=#{error}")
      reject
        status: 500
        body : error

cfapi.createUser = (req,res) ->
#first check if space manager
  orgAuthToken = req.headers['authorization'].split(" ")[1]
  fetchUser(req,res).then (userData)->
    adminOauth.refreshToken (token) ->
       options =
         method: "GET"
         url: "https://#{services["cloud_foundry_api-domain"].value}/v2/users/#{userData.user_id}/managed_spaces?q=organization_guid:#{req.body.org.guid}"
         headers : {'Authorization' : "Bearer #{token.token.access_token}"}
       requestjs options, (error,response,body) ->
         responseBody = JSON.parse(body)
         if(!error && response.statusCode == 200 && responseBody["total_results"] > 0)
           orgAuthToken = token.token.access_token

         doPost("https://#{services["cloud_foundry_api-uaa-domain"].value}/Users",token,buildUaacRequest(req)).then (response)->
            userId = response.body.id
            doPost("https://#{services["cloud_foundry_api-domain"].value}/v2/users",token, { "guid" : userId }).then (response)->
              orgGuid = req.body.org.guid
              doRole('PUT',"Bearer #{orgAuthToken}","organizations",orgGuid,"users",userId).then (response)->
                roleFutures = []
                if(req.body.org.manager)
                  roleFutures.push doRole 'PUT',req.headers['authorization'],"organizations",orgGuid,"managers",userId
                if(req.body.org.auditor)
                  roleFutures.push doRole 'PUT',req.headers['authorization'],"organizations",orgGuid,"auditors",userId

                for space in req.body.spaces
                   if(space.developer)
                     roleFutures.push doRole 'PUT',req.headers['authorization'],"spaces",space.guid,"developers",userId
                   if(space.manager)
                     roleFutures.push doRole 'PUT',req.headers['authorization'],"spaces",space.guid,"managers",userId
                   if(space.auditor)
                     roleFutures.push doRole 'PUT',req.headers['authorization'],"spaces",space.guid,"auditors",userId
                Promise.all(roleFutures).then (responses)->
                  res.status(201).send("user created")
                , (responses)->
                  failedResponses =  ( response for response in responses when response.status!=201 || response.error )
                  res.status(response.status).send(response.body)
              , (response)->
                res.status(response.status).send(response.body)
            , (response)->
              res.status(response.status).send(response.body)
         , (response)->
           res.status(response.status).send(response.body)
  , (error)->
    console.log("Unauthenticated user attempted to createUser")
    res.status(403).send("verboten")


buildUaacRequest = (req)->
  userId =req.body.userId
  identityProvider = req.body.identityProvider
  password = if req.body.password then req.body.password else ""
  userIdComponents = userId.split("@")
  upperId = userIdComponents[0].toUpperCase()
  lowerId = userIdComponents[0].toLowerCase()
  givenName = userIdComponents[0]
  email = if (identityProvider!="uaa") then "#{lowerId}@#{services["cloud_foundry_api-default-email-domain"].value}" else lowerId
  familyName = if(identityProvider!="uaa") then services["cloud_foundry_api-default-email-domain"].value else lowerId

  userNameType = switch(services["cloud_foundry_api-user-name-type"].value)
    when "email" then email
    when "samaccountname" then lowerId
    else ""

  if (userNameType == "") then console.log("User Name Type was not valid.  Defaulting to Email address.");userNameType = email

  uaacRequest =
    "schemas":["urn:scim:schemas:core:1.0"]
    "userName": userNameType
    "name":
      "familyName": "#{familyName}"
      "givenName": "#{givenName}"
    "emails": [
      "value": email
    ]
    "approvals": [ ]
    "active": true
    "verified":  true
    "origin": identityProvider
  if (identityProvider=="uaa")
     uaacRequest["password"] = password
  if (identityProvider!="uaa"&&identityProvider!="ldap")
     uaacRequest["externalId"]= email
  uaacRequest

fetchAllUsers = (token, usersToReturn, page)->
  new Promise (resolve,reject) ->
    options =
      url: "https://#{services["cloud_foundry_api-domain"].value}/v2/users?order-direction=asc&results-per-page=50&page=#{page}"
      headers: {'Authorization': "Bearer " + token.token.access_token}
    requestjs options, (error,response,body) ->
      if(!error && response.statusCode == 200)
        users = JSON.parse(body)
        pages=users.total_pages
        usersToReturn.push user for user in users.resources
        if(page<pages)
          fetchAllUsers(token,usersToReturn,page+1).then ()=>
            resolve(usersToReturn)
          , (error)=>
            reject(error)
        else
          resolve(usersToReturn)
      else
        reject(error)

fetchAllOrganizations = (token,orgsToReturn,page)->
  new Promise (resolve,reject) ->
    options =
      url: "https://#{services["cloud_foundry_api-domain"].value}/v2/organizations?order-direction=asc&page=#{page}&results-per-page=50"
      headers: {'Authorization': token}

    requestjs options, (error,response,body) ->
      if(!error && response.statusCode == 200)
        orgs = JSON.parse(body)
        pages=orgs.total_pages
        quotaPromises = []
        for org in orgs.resources
          do (org) ->
            orgsToReturn.push
              entity :
                name : org.entity.name
              metadata :
                guid : org.metadata.guid
        if(page<pages)
          fetchAllOrganizations(token,orgsToReturn,page+1).then ()=>
            resolve(orgsToReturn)
          , (error)=>
            reject(error)
        else
          resolve(orgsToReturn)
      else
        reject(error)

fetchListCfRequest = (token,resourcesToReturn, level,levelGuid, associationType, filter, page)->

  new Promise (resolve,reject) ->
    options =
      url: "https://#{services["cloud_foundry_api-domain"].value}/v2/#{level}/#{levelGuid}/#{associationType}?order-direction=asc&page=#{page}#{if filter then "&q="+filter else ""}&results-per-page=50"
      headers: {'Authorization': token}

    requestjs options, (error,response,body) ->
      if(!error && response.statusCode == 200)
        orgs = JSON.parse(body)
        pages=orgs.total_pages
        resourcesToReturn.push resource for resource in orgs.resources
        if(page<pages)
          fetchListCfRequest(token,resourcesToReturn,level,levelGuid, associationType,filter,page+1).then ()=>
            resolve(resourcesToReturn)
          , (error)=>
            console.log("fetchListCfRequest error")
            reject(error)
        else
          resolve(resourcesToReturn)
      else
        console.log("fetchListCfRequest status: #{response.statusCode}, error: #{error}")

        reject(error)

module.exports = cfapi
