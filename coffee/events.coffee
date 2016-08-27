ko = require 'knockout'
$ = require 'jquery'
OAuth = require 'oauth'
Cookie = require 'cookie'

model =
  events: ko.observableArray()


$(document).ready ->
  ko.applyBindings model

# OAuth.request('https://api.github.com/events').done (data)->
url = if Cookie.get('username') then 'https://api.github.com/users/'+Cookie.get('username')+'/events' else 'https://api.github.com/events'
OAuth.request(url).done (data)->
  for event in data
    model.events.push event
