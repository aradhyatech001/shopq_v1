<?php
require __DIR__ . '/vendor/autoload.php';
$app = require __DIR__ . '/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use App\Models\Vendor;

$updated = Vendor::where('email', 'vendor@example.com')->update(['status' => 'active']);
if ($updated) {
    echo "Vendor activated\n";
} else {
    echo "No vendor updated\n";
}
