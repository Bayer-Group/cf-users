Promise = require 'promise'
services = require "./serviceBindings"


ao = {}
ao.initOauth2 = ()->
  new Promise (resolve,reject) ->
# Set the client credentials and the OAuth2 server
    credentials =
      clientID: "#{services["cloud_foundry_api-uaa-client-id"].b64}"
      clientSecret: "#{services["cloud_foundry_api-uaa-client-secret"].b64}"
      site: "https://#{services["cloud_foundry_api-uaa-domain"].value}"
      authorizationPath: '/oauth/authorize'
      tokenPath: '/oauth/token'
      revocationPath: '/oauth/oauth/revoke'
    # Initialize the OAuth2 Library
    oauth2 = require('simple-oauth2')(credentials)

    ao.token = null;
    # Save the access token
    saveToken = (error, result) ->
      if (error)
        console.log 'Access Token Error', JSON.stringify(error,0,2)
        reject("error fetching access token")
      else
        ao.token = oauth2.accessToken.create(result);
#        console.log("Access Token",ao)
        console.log("Oauth2 initialized")
        resolve(ao.token)

    oauth2.password.getToken({
      username: "#{services["cloud_foundry_api-portal-admin-id"].b64}",
      password: "#{services["cloud_foundry_api-portal-admin-pw"].b64}"
    }, saveToken)

ao.refreshToken = ( method ) ->
  if ao.token?.expired()
    ao.token.refresh (error, result) ->
      if (error)
        console.log 'Access Token Error', JSON.stringify(error,0,2)
        ao.initOauth2().then method, ()->
          method(ao.token)
      else
        ao.token = result;
#        console.log("Access Token",ao)
        method(ao.token)
  else
    method(ao.token)

module.exports = ao