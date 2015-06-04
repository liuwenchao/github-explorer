'use strict';

window.OAuth = (function($){
  var config = {
    auth_url: 'https://github.com/login/oauth/authorize',
    rate_url: 'https://api.github.com/rate_limit',
    access_token_url: 'https://github.com/login/oauth/access_token',
    // client_id: 'fb9ca053a1044ec94e6c', 
    // client_secret: '7307ea4a063b8da680cd2b83047fc5054702d491', 
    client_id: '676ef133540d6b7d98b8',
    client_secret: 'd3f69322e4954a56ac7d96b28086e3b9df10f801',
    redirect_url: window.location.href,
    scope: 'repo',
    state: $.cookie('_state'),
    isLoggedIn: false
  };

  function request(url) {
    var requestHeaders = $.cookie('_token') ? {
          'Authorization': 'token ' + $.cookie('_token')
        } : {};
    return $.ajax(url, {
      headers: requestHeaders,
      statusCode: {
        401: function() {
          console.error('Not authorized');
        },
        404: function() {
          console.error('Not authorized or Not Found');
        },
        500: function() {
          console.error('Applicaton Error');
        },
        201: function() {
          // 
        },
        204: function() {
          // ajaxSettings.success();
        }
      }
    });
  }

  function login() {
    // var new_state = Math.random().toString().substr(2);
    // $.cookie('_state', new_state);
    // location.href = 
    //   config.auth_url + 
    //   '?' +
    //   $.param({
    //     client_id: config.client_id,
    //     scope: config.scope,
    //     state: new_state,
    //     redirect_uri: config.redirect_url
    //   });
    window.open('https://github.com/settings/tokens');
    var access_token = window.prompt('Paste your Personal access token here, generate one in the opened window, or here: https://github.com/settings/tokens');
    $.cookie('_token', access_token);
    location.reload();
  }

  function postLogin(data) {
    if(data.state === config.state) {
      return $.ajax(config.access_token_url, {
        type: 'POST',
        headers: {
          Accept: 'application/json'
        },
        data:{
          client_id: config.client_id,
          client_secret: config.client_secret,
          code: data.code,
          redirect_url: location.origin + location.pathname
        }, 
        success: function(data) {
          config.isLoggedIn = true;
          $.cookie('_token', data.access_token);
        },
        error: function(data) {
          console.error(data);
        }
      });
    } else {
      console.error('not original state token?');
    }
  }

  function getRate(){
    return request(config.rate_url);
  }

  return {
    config: config,
    login: login,
    postLogin: postLogin,
    getRate: getRate,
    request: request
  };
}(window.jQuery));