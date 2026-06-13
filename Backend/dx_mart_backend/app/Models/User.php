<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    public $timestamps = false;
    protected $fillable = ['name', 'email', 'password', 'status', 'date_time', 'pincode_id'];

    public function pincode() {
        return $this->belongsTo(Pincode::class, 'pincode_id');
    }
    protected $hidden = ['password', 'remember_token'];

    protected function casts(): array {
        return ['password' => 'hashed'];
    }
}
