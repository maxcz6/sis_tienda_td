# Documentacion Oficial Del Frontend

## 1. Identificacion

- Nombre del modulo: `f_tienda`
- Tipo: aplicacion web SPA
- Objetivo: soportar operacion comercial, inventario y administracion de tienda

## 2. Stack Tecnologico

- Vue 3
- Vite
- Pinia
- Vue Router
- Axios
- Tailwind CSS
- vite-plugin-pwa
- @lucide/vue

## 3. Estructura Base

```text
f_tienda/
  src/
    components/
    router/
    stores/
    views/
    App.vue
    main.js
    style.css
  public/
  package.json
  vite.config.js
```

## 4. Responsabilidad Del Frontend

El frontend es responsable de:

- autenticacion de usuario,
- navegacion entre modulos,
- control de acceso visible por rol,
- captura y validacion inicial de datos,
- consumo de la API REST,
- experiencia POS y administracion diaria,
- notificaciones y dialogos globales,
- soporte PWA para experiencia mejorada.

## 5. Inicio Y Configuracion

### Requisitos

- Node.js compatible con Vite 8
- NPM
- URL de API accesible

### Scripts

```bash
npm install
npm run dev
npm run build
npm run preview
```

### Variables De Entorno

- `VITE_API_URL`: URL base de la API. Si no se define, el codigo utiliza `http://localhost:8000/api`.

## 6. Arranque De La Aplicacion

`src/main.js` realiza las siguientes tareas:

- crea la aplicacion Vue;
- registra Pinia;
- registra Vue Router;
- recupera token persistido;
- configura cabecera `Authorization` en Axios si hay sesion previa.

## 7. Navegacion Y Control De Acceso

El archivo `src/router/index.js` define rutas publicas y protegidas.

### Rutas Publicas

- `/login`

### Rutas Protegidas

- `/dashboard`
- `/categorias`
- `/productos`
- `/clientes`
- `/venta`
- `/ventas-historial`
- `/inventario`
- `/usuarios`

### Restriccion Por Rol

La proteccion por rol se configura desde metadatos de ruta:

- `1`: administrador
- `2`: cajero
- `3`: almacenero

Cobertura observada:

- Administrador: acceso total.
- Cajero: clientes, venta, historial de ventas.
- Almacenero: categorias, productos, inventario.

## 8. Gestion De Estado

El frontend usa Pinia para separar preocupaciones:

- `auth.js`: login, logout, sesion y usuario actual.
- `theme.js`: modo claro, oscuro y sistema.
- `dialog.js`: dialogos de confirmacion.
- `toast.js`: notificaciones globales.

## 9. Modulos Funcionales

### Login

- autentica al usuario,
- solicita token a la API,
- redirige a dashboard al completar la sesion.

### Dashboard

- muestra indicadores generales,
- presenta alertas de stock,
- resume ventas y productos destacados.

### Categorias

- registra, lista, actualiza y elimina categorias,
- orientado a administracion y almacenero.

### Productos

- administra catalogo y stock minimo,
- soporta filtrado y mantenimiento del inventario base.

### Clientes

- mantiene cartera de clientes para procesos de venta.

### Venta POS

- busca productos,
- arma carrito,
- selecciona cliente y comprobante,
- registra venta contra la API.

### Historial De Ventas

- consulta ventas realizadas,
- visualiza detalle y soporte de impresion.

### Inventario

- registra entradas y salidas,
- consulta historial de movimientos.

### Usuarios

- administra cuentas y roles,
- uso restringido al administrador.

## 10. Integracion Con API

El frontend consume JSON REST y trabaja con token Bearer.

Principales consumos:

- autenticacion,
- dashboard,
- catalogos,
- clientes,
- productos,
- ventas,
- movimientos de inventario,
- usuarios y roles,
- sincronizacion manual con Supabase.

## 11. Calidad Y Criterios De Ingenieria

Desde una perspectiva de calidad, el frontend se alinea con:

- mantenibilidad: estructura modular por vistas, stores y componentes;
- usabilidad: flujo directo y foco operativo;
- consistencia visual: layout comun y componentes reutilizables;
- seguridad: sesion con token y proteccion de rutas;
- portabilidad: construccion desacoplada de la API mediante variable de entorno.

## 12. Riesgos Y Recomendaciones

- La autorizacion por rol visible en frontend no reemplaza controles backend.
- Conviene formalizar manejo de errores de red y expiracion de token en un interceptor central.
- Debe validarse consistencia de dependencias declaradas en `package.json` durante despliegue.
- En produccion se recomienda documentar estrategia de PWA, cache y actualizacion de service worker.
