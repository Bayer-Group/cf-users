Promise = require 'promise'
services = require "./serviceBindings"
util = require 'util'
debuglog = util.debuglog 'OAUTH'
require 'colors'

ao = {}

expectedScopes = ['scim.write','scim.read','cloud_controller.admin', 'cloud_controller.read','cloud_controller.write','password.write']

validateOauthScopes = (scopes) ->
  validation = (result for result in (scopes?.indexOf expectedScope for expectedScope in expectedScopes) when result < 0)
  console.warn "!!!WARNING!!! The Client ID [#{services["cloud_foundry_api-uaa-client-id"].b64}] may be missing one of these expected scopes [#{expectedScopes}], here are scopes we received from Cloud Foundry for the Client ID [#{scopes}]".bgBlack.yellow if validation.length < 0

ao.initOauth2 = ->
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
    console.log 'initializing the oauth2 library...'
    oauth2 = require('simple-oauth2') credentials

    tokenConfig = 
      username: "#{services["cloud_foundry_api-portal-admin-id"].b64}",
      password: "#{services["cloud_foundry_api-portal-admin-pw"].b64}"

    ao.token = null
    # Save the access token
    oauth2.password.getToken tokenConfig, (error, result) ->
      debuglog 'getToken: error', util.inspect error, depth: null
      debuglog 'getToken: result', util.inspect result, depth: null
      if error
        debuglog 'Access Token Error', JSON.stringify(error,0,2)
        reject "error fetching access token"
      else
        ao.token = oauth2.accessToken.create result
        validateOauthScopes ao?.token?.token?.scope

        console.log 'Oauth2 initialized'
        resolve ao.token

    console.log 'getting the initial oauth2 token...'
    username = services["cloud_foundry_api-portal-admin-id"].b64
    password = services["cloud_foundry_api-portal-admin-pw"].b64
    debuglog "Attemping to log in with #{username}:#{password} and credentials of: ", credentials

ao.refreshToken = (method) ->
  debuglog 'refreshToken: the current ao.token:', util.inspect ao.token, depth: null
  if ao.token?.expired()
    console.log 'the oauth token says it is expired, refreshing token...'
    ao.token.refresh (error, result) ->
      debuglog 'refreshToken: error', util.inspect error, depth: null
      debuglog 'refreshToken: result', util.inspect result, depth: null
      if error
        console.log 'Access Token Error', JSON.stringify(error,0,2)
        ao.initOauth2().then method, ->
          method ao.token
      else
        ao.token = result
        validateOauthScopes ao?.token?.token?.scope
        method ao.token
  else
    if ao.token?.token
      console.log 'the oauth token looks fine, using it...'
    else
      console.warn '!!!WARNING!!! The token does not exist, something is really messed up.'.bgBlack.yellow
    method ao.token

module.exports = ao
