function github_root(repo){
  $.json('https://api.github.com/repos/'+repo+'/contents/', function(data){
    
  });
}