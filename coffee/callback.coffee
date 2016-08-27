OAuth = require 'oauth'
$     = require 'jquery'
Cookie = require 'cookie'

params = {}
for param in window.location.search.substr(1).split('&')
  k = param.substr(0, param.indexOf('='))
  v = param.substr(param.indexOf('=')+1)
  params[k] = v

if params.code
  $.getJSON 'http://2.githubpro.com/t.php?callback=?&code='+params.code, (response)->
    console.log response
    Cookie.set('_token', response.access_token) if response.access_token
    window.location.href = decodeURIComponent(Cookie.get('_callback_url')) ? '/'
