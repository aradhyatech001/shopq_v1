<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class OtpTable extends Model
{
    public $timestamps = false;
    protected $table = 'otp_table';
    protected $fillable = ['email', 'otp', 'expiry', 'reset_token'];
}
