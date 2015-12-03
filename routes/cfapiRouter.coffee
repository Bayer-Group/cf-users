requestjs = require 'request'
express = require 'express'
router = express.Router()
cfapi = require "./cfapi"

router.use (req,res,next) ->
  res.setHeader('Last-Modified', (new Date()).toUTCString());
  next()


router.get '/organizations', cfapi.allOrganizations
router.get '/userinfo', cfapi.userInfo
router.post '/users', cfapi.createUser
router.put '/organizations/:levelGuid/users/:associationGuid', cfapi.putOrgUser
router.put '/:level/:levelGuid/:associationType/:associationGuid', cfapi.putRole
router.delete '/:level/:levelGuid/:associationType/:associationGuid', cfapi.deleteRole
router.get '/users/:userGuid/:associationType', cfapi.listUserAssociation
router.get '/:level/:levelGuid/:associationType', cfapi.listCfRequest
router.get '/users', cfapi.allUsers
router.get '/identityProviders/saml', cfapi.samlIdentityProviders
module.exports = router;

