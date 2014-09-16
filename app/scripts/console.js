// exports = module.exports = new Runner();

// exports.Runner = Runner;
// Runner = function(){}();
function Runner(){
  this.container = document.querySelector('main');
};

runner = new Runner();

Runner.prototype.run = function(form) {
  if (form.command.value) {
    this.render(form.command.value, form.command.value);
    form.command.value = '';
    location.href='#console';
  }
}

Runner.prototype.render = function(cmd, result) {
  var now = new Date();
  var html = [
    '<div class="container theme--user-input"><h4 class="themed">$ ',
    cmd,
    '</h4><div>',
    result,
    '</div></div><hr />'
  ];

  this.container.insertAdjacentHTML('beforeend', html.join(''));
}