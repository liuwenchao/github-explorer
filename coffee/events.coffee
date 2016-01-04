ko = require 'knockout'
$ = require 'jquery'
OAuth = require 'oauth'

model =
  events: ko.observableArray()


$(document).ready ->
  ko.applyBindings model

# OAuth.request('https://api.github.com/events').success (data)->
url = if $.cookie('username') then 'https://api.github.com/users/'+$.cookie('username')+'/events' else 'https://api.github.com/events'
OAuth.request(url).success (data)->
  for event in data
    model.events.push event
