<?php
header('Content-Type: application/json');

$placeId = 606849621;
$cacheFile = __DIR__ . '/small_servers_cache.json';
$cacheTime = 60;

if (file_exists($cacheFile) && (time() - filemtime($cacheFile) < $cacheTime)) {
    echo file_get_contents($cacheFile);
    exit;
}

function getData($url) {
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
    $result = curl_exec($ch);
    curl_close($ch);
    return $result;
}

function getServers($placeId, $order) {
    $url = "https://games.roblox.com/v1/games/$placeId/servers/Public?sortOrder=$order&limit=100";
    $data = json_decode(getData($url), true);
    return $data['data'] ?? [];
}

$servers = [];
foreach (getServers($placeId, "Asc") as $server) {
    if ($server['playing'] >= 2 && $server['playing'] <= 15) {
        $servers[] = $server;
    }
    if (count($servers) >= 100) break;
}

$response = [
    'success' => true,
    'updated' => date('Y-m-d H:i:s'),
    'servers' => $servers
];

file_put_contents($cacheFile, json_encode($response));
echo json_encode($response);