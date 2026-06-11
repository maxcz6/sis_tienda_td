Iniciar localmente (Windows - Powershell)
=======================================

Este proyecto tiene dos partes separadas:

- Backend (Laravel): carpeta `api_tienda`
- Frontend (Vite + Vue): carpeta `f_tienda`

Requisitos mínimos
------------------

- PHP >= 8.3, Composer instalado
- Node >= 16/18 y npm
- SQLite (opcional) o conexión a base de datos configurada en `.env`

Pasos para iniciar el backend (API)
----------------------------------

1. Abrir una terminal y situarse en la carpeta del backend:

```powershell
cd tienda\api_tienda
```

2. Instalar dependencias PHP (Composer):

```powershell
composer install
```

3. Copiar o preparar el `.env` (si no existe):

```powershell
Copy-Item .env.example .env    # PowerShell
# o en CMD: copy .env.example .env
```

4. Generar la clave de la aplicación:

```powershell
php artisan key:generate
```

5. Ejecutar migraciones (local):

```powershell
php artisan migrate
```

Nota: si usas SQLite asegúrate de que `database/database.sqlite` exista o ajusta `DB_CONNECTION` en `.env`.

6. Levantar el servidor de desarrollo (por defecto en el proyecto usamos 127.0.0.1:8000):

```powershell
php artisan serve --host=127.0.0.1 --port=8000
```

Pasos para iniciar el frontend (Vite)
-----------------------------------

1. Abrir otra terminal y situarse en la carpeta del frontend:

```powershell
cd tienda\f_tienda
```

2. Instalar dependencias Node:

```powershell
npm install
```

3. Iniciar servidor de desarrollo Vite (por defecto en http://localhost:5173):

```powershell
npm run dev
```

Ejecutar ambos (backend + frontend)
---------------------------------

Abre dos terminales (o pestañas): en una ejecuta los comandos del backend y en la otra los del frontend. El flujo típico es:

Terminal 1 (API):

```powershell
cd tienda\api_tienda
composer install
Copy-Item .env.example .env
php artisan key:generate
php artisan migrate
php artisan serve --host=127.0.0.1 --port=8000
```

Terminal 2 (Frontend):

```powershell
cd tienda\f_tienda
npm install
npm run dev
```

URLs por defecto
----------------

- Backend: http://127.0.0.1:8000
- Frontend: http://localhost:5173

Notas útiles
------------

- Si usas otra base de datos (Postgres, MySQL), actualiza las variables `DB_*` en `api_tienda/.env` antes de ejecutar `php artisan migrate`.
- Para compilar frontend para producción: en `f_tienda` ejecutar `npm run build`.
- Para ejecutar tests PHP: en `api_tienda` ejecutar `php artisan test`.

Si quieres, puedo añadir atajos de PowerShell (scripts) o un archivo `Makefile`/`scripts` para automatizar estos pasos.
