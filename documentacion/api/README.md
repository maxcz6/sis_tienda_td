# Documentacion Oficial De La API

## 1. Identificacion

- Nombre del modulo: `api_tienda`
- Tipo: API REST
- Framework: Laravel 13
- Lenguaje: PHP 8.3
- Autenticacion: Laravel Sanctum

## 2. Objetivo

La API concentra la logica transaccional del sistema, la persistencia de datos y la exposicion de servicios para el frontend administrativo y POS.

## 3. Estructura Base

```text
api_tienda/
  app/
    Http/Controllers/
    Models/
    Services/
    Traits/
  bootstrap/
  config/
  database/
    migrations/
    seeders/
  routes/
    api.php
  composer.json
```

## 4. Requisitos Tecnicos

- PHP 8.3
- Composer
- Base de datos compatible con configuracion Laravel
- Variables de entorno configuradas

## 5. Arranque Del Servicio

### Instalacion Basica

```bash
composer install
copy .env.example .env
php artisan key:generate
php artisan migrate
php artisan serve
```

### Scripts Relevantes

Desde `composer.json`:

- `composer run setup`: instala dependencias, crea entorno base y ejecuta migraciones.
- `composer run dev`: levanta servidor, cola, logs y frontend asociado.
- `composer run test`: ejecuta pruebas del proyecto.

## 6. Autenticacion Y Seguridad

La API protege la mayor parte de los endpoints con `auth:sanctum`.

### Flujo De Sesion

1. Cliente consume `POST /api/login`.
2. API valida credenciales.
3. API devuelve token Bearer.
4. Cliente usa token en peticiones autenticadas.
5. Cliente cierra sesion mediante `POST /api/logout`.

### Observaciones

- El endpoint `GET /api/me` permite recuperar usuario autenticado.
- La autorizacion fina por rol aun no esta implementada como politica backend formal.
- La configuracion CORS actual debe endurecerse antes de produccion si el despliegue es publico.

## 7. Endpoints Principales

### Publicos

- `GET /api/supabase/status`
- `POST /api/login`

### Protegidos

- `POST /api/logout`
- `GET /api/me`
- `GET /api/dashboard/stats`
- `GET|POST|PUT|PATCH|DELETE /api/categorias`
- `GET|POST|PUT|PATCH|DELETE /api/clientes`
- `GET /api/productos/bajo-stock`
- `GET|POST|PUT|PATCH|DELETE /api/productos`
- `GET /api/tipo-comprobantes`
- `GET /api/ventas`
- `GET /api/ventas/{id}`
- `POST /api/ventas`
- `GET /api/motivos-movimiento`
- `GET /api/inventario/movimientos`
- `POST /api/inventario/movimientos`
- `GET /api/roles`
- `GET|POST|PUT|PATCH|DELETE /api/usuarios`
- `POST /api/supabase/sync-now`

## 8. Modelos De Dominio

### Catalogos Y Seguridad

- `Rol`
- `User`
- `TipoComprobante`
- `MotivoMovimiento`

### Comercial

- `Categoria`
- `Producto`
- `Cliente`
- `Venta`
- `DetalleVenta`

### Inventario E Integracion

- `MovimientoInventario`
- `SyncQueue`

## 9. Responsabilidad De Los Controladores

- `AuthController`: autenticacion, cierre de sesion e identidad actual.
- `DashboardController`: indicadores del tablero principal.
- `CategoriaController`: mantenimiento de categorias.
- `ClienteController`: mantenimiento de clientes.
- `ProductoController`: mantenimiento de productos y consulta de bajo stock.
- `VentaController`: registro y consulta de ventas.
- `MovimientoController`: historial y registro de movimientos de inventario.
- `UsuarioController`: administracion de usuarios y roles.

## 10. Reglas Operativas Generales

- Las operaciones criticas de ventas e inventario se ejecutan en transacciones de base de datos.
- El sistema valida existencia de referencias y condiciones minimas antes de persistir.
- La API conserva trazabilidad de stock mediante movimientos y detalle de ventas.
- Algunos borrados fisicos son sustituidos por desactivacion logica cuando existen relaciones historicas.

## 11. Integracion Con Supabase

La API cuenta con una integracion auxiliar para sincronizacion:

- `SupabaseService` realiza operaciones REST hacia Supabase.
- `SyncsToSupabase` conecta eventos de modelos para enviar o encolar cambios.
- `SyncQueue` conserva reintentos y pendientes cuando no existe conectividad.
- `POST /api/supabase/sync-now` permite forzar procesamiento manual.

## 12. Variables De Entorno Relevantes

Segun configuracion observada, deben considerarse como minimo:

- `APP_NAME`
- `APP_ENV`
- `APP_KEY`
- `APP_DEBUG`
- `APP_URL`
- `DB_CONNECTION`
- `DB_HOST`
- `DB_PORT`
- `DB_DATABASE`
- `DB_USERNAME`
- `DB_PASSWORD`
- `SESSION_DRIVER`
- `QUEUE_CONNECTION`
- `SUPABASE_URL`
- `SUPABASE_KEY`

## 13. Riesgos Y Deuda Tecnica Identificada

- Falta reforzar autorizacion por rol en backend.
- Existen usuarios de respaldo para pruebas en algunos procesos.
- La configuracion abierta de CORS no es ideal para produccion.
- Se recomienda documentar respuestas estandar de error y versionado futuro del API.

## 14. Referencia Funcional

La descripcion detallada de reglas del negocio se encuentra en `logica-negocio.md`, dentro de esta misma carpeta.
