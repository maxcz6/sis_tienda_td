<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\CategoriaController;
use App\Http\Controllers\ClienteController;
use App\Http\Controllers\ProductoController;
use App\Http\Controllers\VentaController;
use App\Http\Controllers\MovimientoController;
use App\Http\Controllers\DashboardController;
use App\Http\Controllers\UsuarioController;

// Rutas públicas
Route::post('/login', [AuthController::class, 'login']);

// Rutas protegidas por Sanctum
Route::middleware('auth:sanctum')->group(function () {
    // Autenticación
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/me', [AuthController::class, 'me']);

    // Dashboard
    Route::get('/dashboard/stats', [DashboardController::class, 'getStats']);

    // Mantenimiento de Categorías
    Route::apiResource('categorias', CategoriaController::class);

    // Mantenimiento de Clientes
    Route::apiResource('clientes', ClienteController::class);

    // Mantenimiento de Productos
    Route::get('productos/bajo-stock', [ProductoController::class, 'lowStock']);
    Route::apiResource('productos', ProductoController::class);

    // Ventas
    Route::get('tipo-comprobantes', [VentaController::class, 'getTipoComprobantes']);
    Route::apiResource('ventas', VentaController::class)->only(['index', 'show', 'store']);

    // Movimientos de Inventario
    Route::get('motivos-movimiento', [MovimientoController::class, 'getMotivos']);
    Route::apiResource('inventario/movimientos', MovimientoController::class)->only(['index', 'store']);

    // Mantenimiento de Usuarios y Roles (idealmente restringido a Administrador en el frontend y políticas)
    Route::get('roles', [UsuarioController::class, 'getRoles']);
    Route::apiResource('usuarios', UsuarioController::class);
});

