<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class HelpEmail extends Model
{
    public $timestamps = false;
    protected $table = 'help_email';
    protected $fillable = ['email'];
}
