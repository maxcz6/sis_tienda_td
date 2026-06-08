<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // Disable foreign key checks for seeding
        if (DB::getDriverName() === 'sqlite') {
            DB::statement('PRAGMA foreign_keys = OFF;');
        } else {
            DB::statement('SET CONSTRAINTS ALL DEFERRED;');
        }

        // Clean tables
        DB::table('movimientos_inventario')->truncate();
        DB::table('detalle_venta')->truncate();
        DB::table('ventas')->truncate();
        DB::table('productos')->truncate();
        DB::table('categorias')->truncate();
        DB::table('clientes')->truncate();
        DB::table('usuarios')->truncate();
        DB::table('roles')->truncate();
        DB::table('tipo_comprobante')->truncate();
        DB::table('motivos_movimiento')->truncate();

        // 1. Roles
        DB::table('roles')->insert([
            ['id_rol' => 1, 'nombre' => 'ADMINISTRADOR'],
            ['id_rol' => 2, 'nombre' => 'CAJERO'],
            ['id_rol' => 3, 'nombre' => 'ALMACENERO'],
        ]);

        // 2. Usuarios
        DB::table('usuarios')->insert([
            [
                'id_usuario' => 1,
                'nombres' => 'Administrador General',
                'username' => 'admin',
                'password' => Hash::make('admin123'),
                'estado' => true,
                'id_rol' => 1
            ],
            [
                'id_usuario' => 2,
                'nombres' => 'Carlos Cajero',
                'username' => 'cajero1',
                'password' => Hash::make('123456'),
                'estado' => true,
                'id_rol' => 2
            ],
            [
                'id_usuario' => 3,
                'nombres' => 'Luis Almacenero',
                'username' => 'almacen1',
                'password' => Hash::make('123456'),
                'estado' => true,
                'id_rol' => 3
            ]
        ]);

        // 3. Categorías
        DB::table('categorias')->insert([
            ['id_categoria' => 1, 'nombre' => 'Abarrotes', 'descripcion' => 'Productos básicos de canasta familiar'],
            ['id_categoria' => 2, 'nombre' => 'Bebidas y Gaseosas', 'descripcion' => 'Gaseosas, aguas y jugos'],
            ['id_categoria' => 3, 'nombre' => 'Lácteos y Embutidos', 'descripcion' => 'Leches, quesos y yogures']
        ]);

        // 4. Productos
        DB::table('productos')->insert([
            [
                'id_producto' => 1,
                'codigo_barras' => '775012345601',
                'nombre' => 'Arroz Extra Costeño 1kg',
                'descripcion' => 'Bolsa de arroz extra',
                'stock_actual' => 50,
                'stock_minimo' => 10,
                'precio_compra' => 3.20,
                'precio_venta' => 3.90,
                'estado' => true,
                'id_categoria' => 1
            ],
            [
                'id_producto' => 2,
                'codigo_barras' => '775098765402',
                'nombre' => 'Gaseosa Inka Kola 3L',
                'descripcion' => 'Botella no retornable',
                'stock_actual' => 24,
                'stock_minimo' => 6,
                'precio_compra' => 8.50,
                'precio_venta' => 11.00,
                'estado' => true,
                'id_categoria' => 2
            ],
            [
                'id_producto' => 3,
                'codigo_barras' => '775123456703',
                'nombre' => 'Leche Gloria Azul 395g',
                'descripcion' => 'Tarro de leche entera',
                'stock_actual' => 48,
                'stock_minimo' => 12,
                'precio_compra' => 3.40,
                'precio_venta' => 4.20,
                'estado' => true,
                'id_categoria' => 3
            ]
        ]);

        // 5. Clientes
        DB::table('clientes')->insert([
            [
                'id_cliente' => 1,
                'nombres' => 'Juan Pérez Gómez',
                'dni_ruc' => '45678912',
                'direccion' => 'Av. Las Flores 450',
                'telefono' => '987654321'
            ],
            [
                'id_cliente' => 2,
                'nombres' => 'Distribuidora Los Andes S.A.C.',
                'dni_ruc' => '20123456789',
                'direccion' => 'Jr. Ayacucho 123',
                'telefono' => '955112233'
            ],
            [
                'id_cliente' => 3,
                'nombres' => 'María Huamán Rojas',
                'dni_ruc' => '10456789123',
                'direccion' => 'Pmo. San Carlos Mz B Lote 4',
                'telefono' => '944887766'
            ]
        ]);

        // 6. Tipo Comprobante
        DB::table('tipo_comprobante')->insert([
            ['id_tipo_comprobante' => 1, 'nombre' => 'BOLETA'],
            ['id_tipo_comprobante' => 2, 'nombre' => 'FACTURA']
        ]);

        // 7. Motivos Movimiento
        DB::table('motivos_movimiento')->insert([
            ['id_motivo' => 1, 'nombre' => 'Compra'],
            ['id_motivo' => 2, 'nombre' => 'Venta'],
            ['id_motivo' => 3, 'nombre' => 'Ajuste'],
            ['id_motivo' => 4, 'nombre' => 'Producto roto']
        ]);

        // 8. Ventas
        DB::table('ventas')->insert([
            [
                'id_venta' => 1,
                'numero_comprobante' => 'B001-000001',
                'fecha_venta' => '2026-05-15 09:30:00',
                'subtotal' => 7.80,
                'igv' => 0.00,
                'total' => 7.80,
                'id_cliente' => 1,
                'id_tipo_comprobante' => 1,
                'id_usuario' => 2
            ],
            [
                'id_venta' => 2,
                'numero_comprobante' => 'F001-000001',
                'fecha_venta' => '2026-05-15 10:15:00',
                'subtotal' => 18.64,
                'igv' => 3.36,
                'total' => 22.00,
                'id_cliente' => 2,
                'id_tipo_comprobante' => 2,
                'id_usuario' => 2
            ],
            [
                'id_venta' => 3,
                'numero_comprobante' => 'B001-000002',
                'fecha_venta' => '2026-05-15 11:00:00',
                'subtotal' => 4.20,
                'igv' => 0.00,
                'total' => 4.20,
                'id_cliente' => 3,
                'id_tipo_comprobante' => 1,
                'id_usuario' => 2
            ]
        ]);

        // 9. Detalle Venta
        DB::table('detalle_venta')->insert([
            [
                'id_detalle' => 1,
                'id_venta' => 1,
                'id_producto' => 1,
                'cantidad' => 2,
                'precio_unitario' => 3.90,
                'subtotal' => 7.80
            ],
            [
                'id_detalle' => 2,
                'id_venta' => 2,
                'id_producto' => 2,
                'cantidad' => 2,
                'precio_unitario' => 11.00,
                'subtotal' => 22.00
            ],
            [
                'id_detalle' => 3,
                'id_venta' => 3,
                'id_producto' => 3,
                'cantidad' => 1,
                'precio_unitario' => 4.20,
                'subtotal' => 4.20
            ]
        ]);

        // 10. Movimientos Inventario
        DB::table('movimientos_inventario')->insert([
            [
                'id_movimiento' => 1,
                'id_producto' => 1,
                'id_motivo' => 1,
                'id_usuario' => 3,
                'tipo_movimiento' => 'ENTRADA',
                'cantidad' => 52,
                'stock_anterior' => 0,
                'stock_nuevo' => 52,
                'fecha_movimiento' => '2026-05-15 08:00:00',
                'observaciones' => 'Carga inicial por compra'
            ],
            [
                'id_movimiento' => 2,
                'id_producto' => 1,
                'id_motivo' => 2,
                'id_usuario' => 2,
                'tipo_movimiento' => 'SALIDA',
                'cantidad' => 2,
                'stock_anterior' => 52,
                'stock_nuevo' => 50,
                'fecha_movimiento' => '2026-05-15 09:30:00',
                'observaciones' => 'Salida por Venta B001-000001'
            ],
            [
                'id_movimiento' => 3,
                'id_producto' => 2,
                'id_motivo' => 2,
                'id_usuario' => 2,
                'tipo_movimiento' => 'SALIDA',
                'cantidad' => 2,
                'stock_anterior' => 26,
                'stock_nuevo' => 24,
                'fecha_movimiento' => '2026-05-15 10:15:00',
                'observaciones' => 'Salida por Venta F001-000001'
            ]
        ]);

        // Re-enable foreign key checks
        if (DB::getDriverName() === 'sqlite') {
            DB::statement('PRAGMA foreign_keys = ON;');
        }
    }
}
