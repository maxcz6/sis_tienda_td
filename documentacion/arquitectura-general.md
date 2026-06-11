# Arquitectura General Del Sistema

## 1. Vision Arquitectonica

`TiendaTodo` implementa una arquitectura cliente-servidor desacoplada:

- Una SPA en `f_tienda` atiende la experiencia de usuario.
- Una API REST en `api_tienda` concentra acceso a datos y reglas transaccionales.
- Una integracion complementaria con Supabase permite sincronizacion de registros.

## 2. Capas Del Sistema

### 2.1 Capa De Presentacion

Responsable de interfaz, navegacion, interaccion y validaciones iniciales.

- Framework: Vue 3.
- Empaquetado: Vite.
- Estado global: Pinia.
- Navegacion: Vue Router.
- Cliente HTTP: Axios.
- Estilos: Tailwind CSS.

### 2.2 Capa De Aplicacion Y Servicios

Responsable de exponer endpoints, validar solicitudes, orquestar transacciones y responder JSON.

- Framework: Laravel 13.
- Autenticacion: Laravel Sanctum.
- Controladores: `AuthController`, `DashboardController`, `CategoriaController`, `ClienteController`, `ProductoController`, `VentaController`, `MovimientoController`, `UsuarioController`.

### 2.3 Capa De Dominio Y Datos

Responsable de persistencia, relaciones y ejecucion de reglas sobre entidades del negocio.

- Modelos: `User`, `Rol`, `Categoria`, `Producto`, `Cliente`, `Venta`, `DetalleVenta`, `MovimientoInventario`, `MotivoMovimiento`, `TipoComprobante`, `SyncQueue`.
- Migraciones para estructuras relacionales.
- Seeders para catalogos base y usuarios iniciales.

### 2.4 Capa De Integracion

Responsable de sincronizacion externa con Supabase.

- Servicio: `SupabaseService`.
- Trait transversal: `SyncsToSupabase`.
- Cola local de pendientes: `sync_queue`.

## 3. Flujo Principal De Operacion

### 3.1 Inicio De Sesion

1. El usuario ingresa credenciales en el frontend.
2. El frontend envia `POST /api/login`.
3. La API valida credenciales y emite token Sanctum.
4. El frontend almacena token y lo reutiliza en solicitudes posteriores.

### 3.2 Venta

1. El cajero selecciona cliente, comprobante e items.
2. El frontend envia `POST /api/ventas`.
3. La API valida stock y estado de productos.
4. La API registra venta, detalle y movimiento de salida en una transaccion.
5. La API descuenta stock y devuelve la venta consolidada.

### 3.3 Movimiento De Inventario

1. El usuario registra entrada o salida.
2. El frontend envia `POST /api/inventario/movimientos`.
3. La API valida existencia, motivo y cantidad.
4. La API recalcula stock en transaccion y registra trazabilidad del movimiento.

## 4. Componentes Principales

## Frontend

- `src/main.js`: inicializacion de la aplicacion y registro de router/Pinia.
- `src/router/index.js`: definicion de rutas y control de acceso por autenticacion y rol.
- `src/stores`: sesion, tema, dialogos y notificaciones.
- `src/views`: paginas por modulo funcional.
- `src/components`: componentes transversales de interfaz.

## API

- `routes/api.php`: contrato principal de endpoints.
- `app/Http/Controllers`: controladores REST.
- `app/Models`: entidades y relaciones.
- `database/migrations`: estructura de base de datos.
- `database/seeders`: datos base del sistema.
- `app/Services` y `app/Traits`: integracion externa y sincronizacion.

## 5. Modelo De Seguridad Actual

- Autenticacion basada en token con Sanctum.
- Rutas protegidas mediante middleware `auth:sanctum`.
- Restriccion funcional por rol aplicada mayormente desde el frontend.
- Variables de entorno para configuracion sensible.

## 6. Riesgos Arquitectonicos Actuales

- La autorizacion por rol aun no se refuerza con politicas backend.
- Los valores de respaldo de usuario autenticado en ventas y movimientos deben tratarse como temporales.
- La sincronizacion con Supabase agrega complejidad operativa y requiere observabilidad.
- CORS abierto para `api/*` puede ser una configuracion valida para desarrollo, pero debe endurecerse para produccion.

## 7. Atributos De Calidad Esperados

La arquitectura busca satisfacer:

- mantenibilidad mediante separacion por modulos;
- confiabilidad mediante transacciones en procesos criticos;
- usabilidad mediante SPA administrativa y POS;
- seguridad mediante autenticacion y control de sesion;
- trazabilidad mediante historial de ventas y movimientos;
- portabilidad mediante configuracion por entorno.
