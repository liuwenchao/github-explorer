ko = require 'knockout'
$ = require 'jquery'
hljs = require 'highlightjs'
OAuth = require 'oauth'
Cookie = require 'cookie'

tree =
  repo: ko.observable(window.location.hash.substr(2))
  viewing: ko.observable()
  children: ko.observableArray()
  rate:
    limit: ko.observable(0)
    remaining: ko.observable(0)
    reset: ko.observable()
  login: OAuth.login

tree.reload = ->
  tree.viewing(false)
  tree.children.removeAll()
  loadChildren(tree)
  if window.history
    window.history.pushState(null, null, window.location.pathname + '#!' + tree.repo())

loadChildren = (parent, url)->
  return false if !tree.repo()
  urlRoot = 'https://api.github.com/repos/' + tree.repo()+'/contents/'
  # parent.children = parent.children || ko.observableArray()
  OAuth.request(url ? url : urlRoot)
  .done (children)->
    refreshQuota()
    for child in children
      file =
        name: child.name
        link: urlRoot + child.path
        type: child.type
        path: child.path
        open: ko.observable(false)
        toggle: if child.type == 'file' then loadContent else toggleChildren
        content: if child.type == 'file' then ko.observable() else false
        postfix: if child.type == 'file' then child.name.substr(child.name.lastIndexOf('.') - child.name.length + 1) else ''
        children: ko.observableArray()
      if child.type == 'dir' then loadChildren file, file.link
      parent.children.push file
  .fail (xhr)->
    refreshQuota()
    if Cookie.get('_token')
      window.alert 'Not found, please verify the repository name'
    else
      OAuth.login()

loadContent = (file, event)->
  if this.content() == undefined
    OAuth.request(this.link).done (fileData)->
      file.content window.atob fileData.content.replace /\n/g,''
      hljs.highlightBlock $('code')[0]
    refreshQuota()
  tree.viewing(this)
  $('li').removeClass 'selected'
  event.target.parentNode.classList.add('selected')
  this.open(true)
  hljs.highlightBlock($('code')[0])

toggleChildren = ->
  this.open !this.open()

refreshQuota = ->
  OAuth.getRate().done (data)->
    tree.rate.limit(data.rate.limit)
    tree.rate.remaining(data.rate.remaining)
    reset = new Date(data.rate.reset*1000)
    tree.rate.reset('Before ' + reset.toLocaleTimeString())

$(document).ready ->
  # if window.location.search
  #   params = window.location.search.substr(1).split('&')
  #   OAuth.postLogin
  #     code: params[0].split('=')[1]
  #     state: params[1]?.split('=')[1]
  #   .always ->
  #     refreshQuota()
  #     loadChildren tree
  # else
  refreshQuota()
  loadChildren tree
  ko.applyBindings tree, document.body
