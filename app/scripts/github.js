'use strict';

var tree = {
  repo: ko.observable('liuwenchao/aha-table'),
  viewing: ko.observable(),
  children: ko.observableArray(),
  reload: function() {
    tree.viewing(undefined);
    tree.children.removeAll();
    loadChildren(tree);
    return false;
  }
};
var ko = window.ko,
    $ = window.$,
    hljs = window.hljs
    ;


function loadChildren(parent, url) {
  var urlRoot = 'https://api.github.com/repos/' + tree.repo()+'/contents/';
  // parent.children = parent.children || ko.observableArray();
  $.getJSON(url ? url : urlRoot, function(children){
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
    window.alert('Does not exist, check the path again.');
  });
}

var loadContent = function() {
  if (this.content() === undefined) {
    $.getJSON(this.link, function(fileData) {
      this.content(atob(fileData.content));
    }.bind(this));
  }
  tree.viewing(this);
  this.open(true);
  hljs.highlightBlock($('code')[0]);
};

var toggleChildren = function() {
  this.open(!this.open());
};

$(document).ready(function(){
  loadChildren(tree);
  ko.applyBindings(tree, document.body);
});