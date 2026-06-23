<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class HelpWhatsapp extends Model
{
    public $timestamps = false;
    protected $table = 'help_whatsapp';
    protected $fillable = ['whatsapp_no'];
}
