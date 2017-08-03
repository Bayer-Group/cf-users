Promise = require 'promise'
services = require "./serviceBindings"

uao = {}
uao.initOauth2 = ()->
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
    tokenConfig = {}
    console.log("Initializing UAA Admin Access Token")

    uao.token = null;
    # Save the access token
    oauth2.client.getToken tokenConfig, (error, result) ->
      if (error)
        console.log 'UAA Access Token Error', JSON.stringify(error,0,2)
        reject("error fetching UAA access token")
      else
        uao.token = oauth2.accessToken.create(result);
#        console.log("UAA Admin Access Token",uao)
        console.log("UAA Oauth2 initialized")
        resolve(uao.token)

uao.refreshToken = ( method ) ->
  if uao.token?.expired()
    uao.token.refresh (error, result) ->
      if (error)
        console.log 'UAA Access Token Error', JSON.stringify(error,0,2)
        uao.initOauth2().then method, ()->
          method(uao.token)
      else
        uao.token = result;
#        console.log("UAA Admin Access Token",uao)
        method(uao.token)
  else
    method(uao.token)

module.exports = uao
