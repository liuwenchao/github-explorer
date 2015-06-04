'use strict';

var ko = window.ko,
    $ = window.$,
    hljs = window.hljs,
    OAuth = window.OAuth
    ;
    
var tree = {
  repo: ko.observable('liuwenchao/aha-table'),
  viewing: ko.observable(),
  children: ko.observableArray(),
  reload: function() {
    tree.viewing(undefined);
    tree.children.removeAll();
    loadChildren(tree);
    return false;
  },
  rate: {
    limit: ko.observable(),
    remaining: ko.observable(),
    reset: ko.observable()
  },
  login: OAuth.login,
  isLoggedIn: ko.observable(false)
};


function loadChildren(parent, url) {
  var urlRoot = 'https://api.github.com/repos/' + tree.repo()+'/contents/';
  // parent.children = parent.children || ko.observableArray();
  OAuth.request(url ? url : urlRoot)
  .success(function(children){
    monitorRate();
    for (var i = children.length - 1; i >= 0; i--) {
      var child = children[i];
      var file = {
        name: child.name, 
        link: urlRoot + child.path,
        type: child.type,
        path: child.path,
        open: ko.observable(false),
        toggle: child.type === 'file' ? loadContent : toggleChildren,
        content: child.type === 'file' ? ko.observable() : false,
        postfix: child.type === 'file' ? child.name.substr(child.name.lastIndexOf('.') - child.name.length + 1) : '',
        children: ko.observableArray()
      };
      switch(child.type) {
        case 'dir':
          loadChildren(file, file.link);
          break;
        case 'file':
        case 'symlink':
        case 'submodule':
          break;
        default:
          break;
      }
      parent.children.push(file);
    }
  })
  .fail(function(){
    monitorRate();
    tree.isLoggedIn(false);
    window.alert('Path error or limit is reached for API calling.');
  });
}

var loadContent = function(file, event) {
  if (this.content() === undefined) {
    OAuth.request(this.link).success(function(fileData) {
      this.content(atob(fileData.content));
      hljs.highlightBlock($('code')[0]);
    }.bind(this));
    monitorRate();
  }
  tree.viewing(this);
  $('li').removeClass('selected');
  event.target.parentNode.classList.add('selected');
  this.open(true);
  hljs.highlightBlock($('code')[0]);
};

var toggleChildren = function() {
  this.open(!this.open());
};

var monitorRate = function() {
  OAuth.getRate().success(function(data){
    tree.rate.limit(data.rate.limit);
    tree.rate.remaining(data.rate.remaining);
    var reset = new Date(data.rate.reset*1000);
    tree.rate.reset(reset.toLocaleTimeString());
    tree.isLoggedIn(OAuth.config.isLoggedIn);
    if (data.rate.remaining === 0) {
      tree.isLoggedIn(false);
    }
  });
};

$(document).ready(function(){
  if (window.location.search) {
    var params = window.location.search.substr(1).split('&');
    OAuth.postLogin({
      code: params[0].split('=')[1], 
      state: params[1].split('=')[1]
    }).always(function(){
      monitorRate();
      loadChildren(tree);
    });
  } else {
    monitorRate();
    loadChildren(tree);
  }
  ko.applyBindings(tree, document.body);
});
