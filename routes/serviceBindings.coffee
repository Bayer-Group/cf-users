atob = require 'atob'
defaults = {
  "user-provided": []
}

parseBindings = (bindingsObject) ->
  bindings = {}
  for service in bindingsObject["user-provided"]
    for own key,value of service.credentials when key != "alias"
      bindings["#{service.credentials.alias}-#{key}"] = {}
      bindings["#{service.credentials.alias}-#{key}"].value = value
      try
         bindings["#{service.credentials.alias}-#{key}"].b64 = atob value
      catch error
  bindings

exports = parseBindings if process.env.VCAP_SERVICES then JSON.parse(process.env.VCAP_SERVICES) else defaults

module.exports = exports