<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class MotivoMovimiento extends Model
{
    protected $table = 'motivos_movimiento';
    protected $primaryKey = 'id_motivo';
    public $incrementing = false;
    public $timestamps = false;

    protected $fillable = [
        'id_motivo',
        'nombre',
    ];

    public function movimientos(): HasMany
    {
        return $this->hasMany(MovimientoInventario::class, 'id_motivo', 'id_motivo');
    }
}
