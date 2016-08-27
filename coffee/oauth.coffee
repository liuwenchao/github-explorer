$ = require 'jquery'
Cookie = require 'cookie'
require 'script!jquery.cookie/jquery.cookie.js'

config =
  auth_url: 'https://github.com/login/oauth/authorize'
  rate_url: 'https://api.github.com/rate_limit'
  access_token_url: 'https://github.com/login/oauth/access_token'
  # client_id: 'fb9ca053a1044ec94e6c'
  # client_secret: '7307ea4a063b8da680cd2b83047fc5054702d491'
  client_id: '676ef133540d6b7d98b8'
  client_secret: 'd3f69322e4954a56ac7d96b28086e3b9df10f801'
  redirect_url: window.location.href
  scope: 'repo'
  state: Cookie.get('_state')
  isLoggedIn: false

request = (url)->
  $.ajax url,
    headers:
      'Authorization': 'token ' + Cookie.get('_token')
    statusCode:
      401: -> console.error 'Not authorized'
      403: -> console.error 'Forbidden'
      404: -> console.error 'Not authorized or Not Found'
      500: -> console.error 'Applicaton Error'
      201: ->
      204: -> # ajaxSettings.done();

postLogin = (data)->
  if data.state == config.state
    $.ajax config.access_token_url,
      type: 'POST',
      headers:
        Accept: 'application/json'
      data:
        client_id: config.client_id
        client_secret: config.client_secret
        code: data.code
        redirect_url: location.origin + location.pathname
      done: (data)->
        config.isLoggedIn = true
        Cookie.set '_token', data.access_token
      error: (data)->
        console.error data
  else
    console.error 'not original state token?'

getRate = ->
  request config.rate_url

module.exports =
  config: config
  postLogin: postLogin
  getRate: getRate
  request: request
