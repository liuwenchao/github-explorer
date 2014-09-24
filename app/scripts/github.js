var repo = 'liuwenchao/aha-table';
var root = 'https://api.github.com/repos/'+repo+'/contents/';
var tree = {
  name: ko.observable(repo),
  viewing: ko.observable(),
  children: ko.observableArray()
};

function loadChildren(url, parent) {
  // parent.children = parent.children || ko.observableArray();
  $.getJSON(url, function(children){
    for (var i = children.length - 1; i >= 0; i--) {
      var child = children[i];
      var file = {
        name: child.name, 
        link: root + child.path,
        type: child.type,
        path: child.path,
        postfix: child.type === 'file' ? child.name.substr(child.name.lastIndexOf('.') - child.name.length + 1) : '',
        open: ko.observable(false),
        click: child.type === 'file' ? loadContent : toggleChildren,
        content: child.type === 'file' ? ko.observable() : false,
        children: ko.observableArray()
      };
      switch(child.type) {
        case 'dir':
          loadChildren(file.link, file, false);
          break;
        case 'file':
        case 'symlink':
        case 'submodule':
        default:
          break;
      }
      parent.children.push(file);
    };
  });
}

function loadContent() {
  if (!this.content()) {
    var file = this;
    $.getJSON(file.link, function(fileData) {
      file.content(atob(fileData.content));
    });
  }
  tree.viewing(this);
  this.open(true);
  hljs.highlightBlock($('code')[0]);
}

function toggleChildren() {
  this.open(!this.open());
}

hljs.initHighlightingOnLoad();
$(document).ready(function(){
  loadChildren(root, tree);
  ko.applyBindings(tree, document.body);
});