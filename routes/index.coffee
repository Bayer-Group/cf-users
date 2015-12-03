express = require('express');
router = express.Router();
services = require('./serviceBindings')

#/* GET home page. */
router.get '/', (req, res, next) ->
  res.render('index', { title: 'Cloud Foundry Users' , appRoot: '/cf-users', page: "roles", host: req.hostname, loginDomain : services["cloud_foundry_api-login-domain"].value, query: "{}"});
router.get '/:page', (req, res, next) ->
  res.render('index', { title: 'Cloud Foundry Users' , appRoot: '/cf-users', page: req.params.page, host: req.hostname,loginDomain : services["cloud_foundry_api-login-domain"].value, query: if req.query? then  JSON.stringify(req.query) else "{}" });

module.exports = router;
