<?php
header('content-type: application/json; charset=utf-8');

$ch = curl_init( 'https://github.com/login/oauth/access_token' );
curl_setopt( $ch, CURLOPT_POST, 1);
curl_setopt( $ch, CURLOPT_POSTFIELDS, 'client_id=0cc599272ba6f892ca92&client_secret=e0fddf4bc87cb605039c73366c6feb53fabe79f0&code='.@$_GET['code']);
curl_setopt( $ch, CURLOPT_HEADER, 0);
curl_setopt( $ch, CURLOPT_RETURNTRANSFER, 1);

parse_str(curl_exec($ch), $response);
echo @$_GET['callback'] . '('.json_encode($response).')';
exit();
?>
