var repo = 'liuwenchao/aha-table';
var root = 'https://api.github.com/repos/'+repo+'/contents/';
var tree = {
  name: ko.observable(repo),
  viewing: ko.observable(),
  children: ko.observableArray()
};

function load_children(url, parent) {
  // parent.children = parent.children || ko.observableArray();
  $.getJSON(url, function(children){
    for (var i = children.length - 1; i >= 0; i--) {
      var child = children[i];
      var file = {
        name: child.name, 
        link: root + child.path,
        type: child.type,
        path: child.path,
        click: child.type === 'file' ? load_content : false,
        content: child.type === 'file' ? ko.observable() : false,
        children: ko.observableArray()
      };
      switch(child.type) {
        case 'dir':
          load_children(file.link, file, false);
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

function load_content() {
  if (!this.content()) {
    var file = this;
    $.getJSON(file.link, function(file_data) {
      file.content(atob(file_data.content));
    });
  }
  tree.viewing(this);
}

$(document).ready(function(){
  load_children(root, tree);
  ko.applyBindings(tree, document.body);
});