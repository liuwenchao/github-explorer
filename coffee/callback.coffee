OAuth = require 'oauth'
$     = require 'jquery'

params = {}
for param in window.location.search.substr(1).split('&')
  k = param.substr(0, param.indexOf('='))
  v = param.substr(param.indexOf('=')+1)
  params[k] = v
$.ajax
  type: 'post'
  url: 'https://github.com/login/oauth/access_token'
  # contentType: 'application/json; charset=UTF-8'
  dataType: 'json'
  jsonp: false
  data:
    client_id: '0cc599272ba6f892ca92'
    client_secret: 'e0fddf4bc87cb605039c73366c6feb53fabe79f0'
    code: params.code
    # state:
  success: (response) ->
    $.cookie('_token', response.access_token)
    window.location.href = '/index.html'
