# Documentacion Oficial Del Sistema TiendaTodo

## 1. Proposito

Este directorio concentra la documentacion oficial del sistema `TiendaTodo`, separada por dominios de ingenieria para facilitar mantenimiento, auditoria, transferencia de conocimiento y evolucion del software.

La documentacion se organiza siguiendo buenas practicas alineadas a normas y marcos de referencia de ingenieria de sistemas y software, especialmente:

- ISO/IEC/IEEE 12207 para procesos del ciclo de vida del software.
- ISO/IEC 25010 para caracteristicas de calidad del producto.
- ISO/IEC 27001 y 27002 como referencia para controles de seguridad de la informacion.
- ISO 9001 como referencia de gestion documental y trazabilidad.
- IEEE 1016 como referencia de descripcion de arquitectura y diseno.

Importante: esta carpeta **no certifica** cumplimiento formal de "todas las ISO". Lo que si entrega es una base documental formal, auditable y alineada a dichos estandares para apoyar cumplimiento institucional, academico o empresarial.

## 2. Alcance Del Sistema

`TiendaTodo` es un sistema de gestion comercial orientado a operaciones de tienda, con los siguientes modulos principales:

- Autenticacion y sesion de usuarios.
- Dashboard operativo.
- Gestion de categorias.
- Gestion de productos.
- Gestion de clientes.
- Punto de venta.
- Historial de ventas.
- Movimientos de inventario.
- Gestion de usuarios y roles.
- Sincronizacion complementaria con Supabase.

## 3. Arquitectura General

El sistema se compone de dos bloques principales:

- `frontend`: aplicacion SPA construida con Vue 3, Vite, Pinia, Vue Router, Axios y Tailwind CSS.
- `api`: backend REST construido con Laravel 13, PHP 8.3 y Sanctum para autenticacion.

La comunicacion entre ambas capas se realiza mediante HTTP JSON sobre rutas `/api/*`.

## 4. Estructura Documental

- `frontend/README.md`: documentacion oficial del frontend.
- `api/README.md`: documentacion oficial de la API.
- `api/logica-negocio.md`: reglas funcionales y operativas del negocio implementadas en backend.
- `arquitectura-general.md`: descripcion arquitectonica del sistema completo.
- `cumplimiento-iso.md`: matriz de alineacion documental con normas ISO/IEC e IEEE.

## 5. Principios De Documentacion

La presente documentacion busca cumplir con los siguientes criterios:

- Separacion clara entre vista, servicios y reglas de negocio.
- Trazabilidad entre componentes, rutas, procesos y modulos.
- Claridad operativa para desarrollo, pruebas, mantenimiento y despliegue.
- Identificacion de riesgos y restricciones actuales del sistema.
- Base reutilizable para auditorias, sustentaciones o ampliaciones futuras.

## 6. Restricciones Identificadas

Durante el levantamiento documental se identificaron las siguientes condiciones del estado actual:

- La autorizacion por rol se implementa principalmente en el frontend, no mediante politicas robustas en backend.
- Existen valores de respaldo para usuario autenticado en algunos procesos de venta e inventario usados como soporte de pruebas.
- La integracion con Supabase es complementaria y depende de disponibilidad de red y variables de entorno.

## 7. Uso Recomendado

Se recomienda usar esta carpeta como fuente oficial para:

- induccion tecnica del proyecto,
- entregables academicos o institucionales,
- auditorias internas,
- soporte de mantenimiento,
- planificacion de mejoras de seguridad, calidad y escalabilidad.
