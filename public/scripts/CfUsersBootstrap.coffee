jQuery = require 'jquery'
Router = require "./Router"
JSO = require "./lib/jso/jso"
q = document.URL.split("?")
query = {}
if(q.length>1)
  for pair in q[1].split('&')
    nameValue = pair.split('=')
    query[nameValue[0]] = nameValue[1]
path = q[0].split('/')
opts =
  provider : "smarf"
  response_type:"code"
  client_id: "cf_portal_client"
  redirect_uri: "https://#{location.host}/cf-users/roles"
  authorization : "https://#{window.loginDomain}/oauth/authorize"
  scopes :
    request :["openid","cloud_controller.read","cloud_controller.write","scim.read","scim.write","password.write"]

JSO.enablejQuery($);
jso = new JSO(opts);

jso.callback();

jso.getToken (token) ->
 ajaxSettings =
   oauth:
     scopes :
       request :["openid","cloud_controller.read","cloud_controller.write","scim.read","scim.write","password.write" ]
   datatype: 'jsonp'
   headers :
     Authorization : "Bearer " + token.access_token
 $.ajaxSetup ajaxSettings
 $(document). ready () ->
   router = new Router({host: "#{location.host}", page:"#{path[path.length-1]}", query : query, jso: jso})
,
opts

