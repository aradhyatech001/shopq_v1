<?php
$base = 'http://192.168.1.5:8000/api';
$token = '3|gUMGcLNEKoKSePsRJqGaHLpl6P1dEfxd7kIHyzqk384aaf16';

function req($method, $path, $data = null) {
    global $base, $token;
    $url = $base . $path;
    $opts = [
        'http' => [
            'method' => $method,
            'header' => "Authorization: Bearer $token\r\n" . ($data?"Content-Type: application/json\r\n":""),
            'ignore_errors' => true,
        ]
    ];
    if ($data) {
        $body = json_encode($data);
        $opts['http']['content'] = $body;
    }
    $ctx = stream_context_create($opts);
    $start = microtime(true);
    $resp = @file_get_contents($url, false, $ctx);
    $time = round((microtime(true)-$start)*1000,2);
    $status = 0;
    if (isset($http_response_header) && is_array($http_response_header)) {
        foreach ($http_response_header as $h) {
            if (preg_match('#HTTP/\d\.\d\s+(\d{3})#', $h, $m)) { $status = intval($m[1]); break; }
        }
    }
    $out = [
        'url'=>$url,
        'method'=>$method,
        'status'=>$status,
        'time_ms'=>$time,
        'raw'=> $resp,
    ];
    echo json_encode($out, JSON_PRETTY_PRINT) . "\n";
    return [$status, $resp];
}

echo "SMOKE TEST - Vendor endpoints\n";
$results = [];

$tests = [
    ['GET','/vendor/profile',null],
    ['GET','/vendor/products',null],
    ['GET','/vendor/orders',null],
    ['GET','/vendor/pincodes',null],
    ['POST','/vendor/pincodes/update',['pincodes'=>[560001]]],
];

foreach ($tests as $t) {
    [$s,$r] = req($t[0], $t[1], $t[2] ?? null);
    $results[] = ['path'=>$t[1],'status'=>$s,'body'=>$r];
    usleep(200000);
}

// Try safe POSTs that may be blocked by subscription; capture responses
[$s,$r] = req('POST','/vendor/products/insert', [
    'name'=>'Smoke Test Product '.time(),
    'description'=>'Auto smoke test',
    'main_category_id'=>1,
    'subcategory_id'=>1,
    'types'=>'test',
    'is_active'=>1
]);
$results[] = ['path'=>'/vendor/products/insert','status'=>$s,'body'=>$r];

// If product created, try variant/info/highlight/upload
$prodId = null;
if ($s>=200 && $s<300) {
    $json = json_decode($r, true);
    if (isset($json['product']['id'])) $prodId = $json['product']['id'];
}

if ($prodId) {
    req('POST','/vendor/products/variant',['product_id'=>$prodId,'variant_type'=>'default','price'=>10,'stock'=>5]);
    req('POST','/vendor/products/info',['product_id'=>$prodId,'title'=>'Info title','value'=>'Info value']);
    req('POST','/vendor/products/highlight',['product_id'=>$prodId,'title'=>'Highlight title']);
    // upload-image with base64 tiny PNG
    $png = base64_encode(file_get_contents(__DIR__.'/public/favicon.ico')?:'');
    req('POST','/vendor/products/upload-image',['product_id'=>$prodId,'image_name'=>'smoke.png','image_data'=>$png]);
    req('POST','/vendor/products/update-stock',['product_id'=>$prodId,'is_active'=>1]);
    req('POST','/vendor/products/update-type',['product_id'=>$prodId,'types'=>'test,smoke']);
}

file_put_contents(__DIR__.'/smoke_results.json', json_encode($results, JSON_PRETTY_PRINT));
echo "Results written to smoke_results.json\n";
