<?php
//var_dump($_SERVER);
// 予め CA の CN を読み込み
$CACN_FILEPATH = '/etc/ssl/private/CA/.cacn';
if(!file_exists($CACN_FILEPATH)) {
    header('HTTP/1.1 500 Internal Server Error.');
    echo 'コモンネームが読み込めませんでした。';
    exit();
}
$CA_CN = str_replace(["\r\n", "\r", "\n"], '', file_get_contents($CACN_FILEPATH));

// クライアント証明書
if(!isset($_SERVER['SSL_CLIENT_I_DN_CN']) || empty($_SERVER['SSL_CLIENT_I_DN_CN'])) {
    header('HTTP/1.1 403 Forbidden.');
    echo 'ブラウザにクライアント証明書がインポートされていません。';
    exit();
}
else if($_SERVER['SSL_CLIENT_I_DN_CN'] !== $CA_CN) {
    header('HTTP/1.1 403 Forbidden.');
    echo '誤ったクライアント証明書を使用しています。';
    exit();
}
?>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Solemn Oath</title>
</head>
<body>
    <h1>Solemn Oath</h1>
    <p>認証テスト</p>
</body>
</html>