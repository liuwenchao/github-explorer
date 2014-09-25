var tree = {
  repo: ko.observable('liuwenchao/aha-table'),
  viewing: ko.observable(),
  children: ko.observableArray()
};

function loadChildren(parent, url) {
  var url_root = 'https://api.github.com/repos/' + tree.repo()+'/contents/';
  // parent.children = parent.children || ko.observableArray();
  $.getJSON(url ? url : url_root, function(children){
    for (var i = children.length - 1; i >= 0; i--) {
      var child = children[i];
      var file = {
        name: child.name, 
        link: url_root + child.path,
        type: child.type,
        path: child.path,
        open: ko.observable(false),
        click: child.type === 'file' ? loadContent : toggleChildren,
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
        default:
          break;
      }
      parent.children.push(file);
    };
  })
  .fail(function(){
    alert('Does not exist, check the path again.');
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

function loadRepo(newRepo) {
  repo = newRepo;
  tree.viewing(undefined);
  tree.children.removeAll();
  loadChildren(tree);
}

function search(event) {
  var key = event.key || event.which
  if (key == 191) {
    //fetch repos of this user.
  }
}

hljs.initHighlightingOnLoad();
$(document).ready(function(){
  loadChildren(tree);
  ko.applyBindings(tree, document.body);
});