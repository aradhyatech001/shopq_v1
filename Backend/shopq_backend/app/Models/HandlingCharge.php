<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class HandlingCharge extends Model
{
    public $timestamps = false;
    protected $table = 'handling_charge';
    protected $fillable = ['amount'];
}
