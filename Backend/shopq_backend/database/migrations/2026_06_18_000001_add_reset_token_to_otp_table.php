<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Adds `reset_token` to otp_table so that verifyOtp() can issue a one-time
 * password-reset token that resetPassword() must present, breaking the
 * "skip OTP verification" attack (H3 security fix).
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::table('otp_table', function (Blueprint $table) {
            if (!Schema::hasColumn('otp_table', 'reset_token')) {
                $table->string('reset_token', 128)->nullable()->after('expiry');
            }
        });
    }

    public function down(): void
    {
        Schema::table('otp_table', function (Blueprint $table) {
            if (Schema::hasColumn('otp_table', 'reset_token')) {
                $table->dropColumn('reset_token');
            }
        });
    }
};
