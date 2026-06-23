<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class HelpCall extends Model
{
    public $timestamps = false;
    protected $table = 'help_call';
    protected $fillable = ['call_help'];
}
