ko = require 'knockout'
$ = require 'jquery'
hljs = require 'highlightjs'
OAuth = require 'oauth'

tree =
  repo: ko.observable(window.location.hash.substr(2))
  viewing: ko.observable()
  children: ko.observableArray()
  reload: ->
    tree.viewing()
    tree.children.removeAll()
    loadChildren(tree)
    if window.history
      window.history.pushState(null, null, window.location.pathname + '#!' + tree.repo())
    return false
  rate:
    limit: ko.observable(0)
    remaining: ko.observable(0)
    reset: ko.observable()
  getToken: ->
    tree.showTokenForm(true)
    if window.confirm 'Please generate a Personal Access Token in the new opened window, and paste in the bottom of the page.'
      window.open 'https://github.com/settings/tokens/new'
  showTokenForm: ko.observable(false)
  login: (form)->
    $.cookie('_token', form.token.value)
    location.reload()
  isLoggedIn: ko.observable(false)

loadChildren = (parent, url)->
  return false if !tree.repo()
  urlRoot = 'https://api.github.com/repos/' + tree.repo()+'/contents/'
  # parent.children = parent.children || ko.observableArray()
  OAuth.request(url ? url : urlRoot)
  .success (children)->
    monitorRate()
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
  .fail ->
    monitorRate()
    tree.isLoggedIn(false)
    window.alert('Path error or limit is reached for API calling.')

loadContent = (file, event)->
  if this.content() == undefined
    OAuth.request(this.link).success (fileData)->
      file.content(window.atob(fileData.content))
      hljs.highlightBlock($('code')[0])
    monitorRate()
  tree.viewing(this)
  $('li').removeClass('selected')
  event.target.parentNode.classList.add('selected')
  this.open(true)
  hljs.highlightBlock($('code')[0])

toggleChildren = ->
  this.open !this.open()

monitorRate = ->
  OAuth.getRate().success (data)->
    tree.rate.limit(data.rate.limit)
    tree.rate.remaining(data.rate.remaining)
    reset = new Date(data.rate.reset*1000)
    tree.rate.reset(reset.toLocaleTimeString())
    tree.isLoggedIn(OAuth.config.isLoggedIn)
    if data.rate.remaining == 0
      tree.isLoggedIn(false)

$(document).ready ->
  if window.location.search
    params = window.location.search.substr(1).split('&')
    OAuth.postLogin
      code: params[0].split('=')[1]
      state: params[1]?.split('=')[1]
    .always ->
      monitorRate()
      loadChildren tree
  else
    monitorRate()
    loadChildren tree
  ko.applyBindings tree, document.body