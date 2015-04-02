=======
Github Explorer
=====

Browse github repositories like in your editor, handy if you just need to browse the codes w/o clone it.

[Click here to use it](http://liuwenchao.github.io/github-explorer/index.html)


## Development

Make sure [nodejs](http://nodejs.org) and [gulp](http://gulpjs.com) is installed:

```
sudo apt-get install nodejs
sudo apt-get install npm

# you can switch to more suitable registry to you.
# North America: http://npm.strongloop.com/ http://registry.nodejitsu.com/
# Europe: http://npmjs.eu/
# Asia: http://registry.npm.taobao.org/
# sudo npm config set registry "http://registry.npm.taobao.org/" 

sudo npm install -g npm #update npm
sudo npm install -g gulp
```

Then run:

```
git clone git@github.com:liuwenchao/github-explorer.git # skip this if you have already downloaded/cloned the repository.
cd github-explorer
npm install # see Trouble Shooting if you got error here.
gulp serve
```

## Deployment

```
gulp deploy
```
