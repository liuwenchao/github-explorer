OAuth = require 'oauth'
$     = require 'jquery'

params = {}
for param in window.location.search.substr(1).split('&')
  k = param.substr(0, param.indexOf('='))
  v = param.substr(param.indexOf('=')+1)
  params[k] = v

$.getJSON 'http://2.githubpro.com/t.php?callback=?&code='+params.code, (response)->
  console.log response
  $.cookie('_token', response.access_token) if response.access_token
  window.location.href = decodeURIComponent($.cookie('_callback_url')) ? '/'


# <?php
# header('content-type: application/json; charset=utf-8');
#
# $ch = curl_init( 'https://github.com/login/oauth/access_token' );
# curl_setopt( $ch, CURLOPT_POST, 1);
# curl_setopt( $ch, CURLOPT_POSTFIELDS, 'client_id=0cc599272ba6f892ca92&client_secret=e0fddf4bc87cb605039c73366c6feb53fabe79f0&code='.@$_GET['code']);
# curl_setopt( $ch, CURLOPT_HEADER, 0);
# curl_setopt( $ch, CURLOPT_RETURNTRANSFER, 1);
#
# parse_str(curl_exec($ch), $response);
# echo @$_GET['callback'] . '('.json_encode($response).')';
# exit();
# ?>
