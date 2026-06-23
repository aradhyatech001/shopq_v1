<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class DeliverTime extends Model
{
    public $timestamps = false;
    protected $table = 'deliver_time';
    protected $fillable = ['time'];
}
