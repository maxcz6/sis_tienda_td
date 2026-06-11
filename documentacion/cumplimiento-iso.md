# Matriz De Alineacion Con ISO E IEEE

## 1. Objetivo

Este documento relaciona la documentacion del proyecto con normas de referencia usadas habitualmente en ingenieria de sistemas y software.

## 2. Alcance

La matriz expresa **alineacion documental y tecnica**. No reemplaza auditorias, certificaciones ni evaluaciones formales de conformidad.

## 3. Matriz De Alineacion

| Norma | Enfoque | Evidencia documental en este repositorio | Estado |
| --- | --- | --- | --- |
| ISO/IEC/IEEE 12207 | Procesos del ciclo de vida del software | `documentacion/README.md`, `documentacion/arquitectura-general.md`, `documentacion/frontend/README.md`, `documentacion/api/README.md` | Parcial alineado |
| ISO/IEC 25010 | Calidad del producto software | atributos de calidad, riesgos y mantenibilidad documentados en arquitectura, frontend y API | Parcial alineado |
| ISO/IEC 27001 | Seguridad de la informacion | controles base descritos para autenticacion, variables de entorno y recomendaciones de endurecimiento | Parcial alineado |
| ISO/IEC 27002 | Buenas practicas de seguridad | recomendaciones sobre roles backend, CORS, manejo de secretos y endurecimiento operativo | Parcial alineado |
| ISO 9001 | Gestion documental y trazabilidad | carpeta unica de documentacion oficial, separacion por modulos y evidencia de restricciones | Parcial alineado |
| IEEE 1016 | Descripcion de arquitectura de software | `documentacion/arquitectura-general.md` | Alineado |

## 4. Evidencias De Cumplimiento Parcial

### Gestion Documental

- Existe un repositorio central de documentacion tecnica.
- Se separa documentacion por componente y por responsabilidad.
- Se registran alcance, restricciones y recomendaciones.

### Arquitectura

- Se identifica estructura por capas.
- Se documentan componentes, flujos y riesgos.
- Se define integracion entre frontend, API y sincronizacion externa.

### Calidad Del Producto

- Se reconocen atributos de mantenibilidad, usabilidad, seguridad y trazabilidad.
- Se documentan reglas transaccionales en procesos criticos.
- Se registran riesgos y deuda tecnica.

### Seguridad

- Se documenta autenticacion mediante Sanctum.
- Se identifican brechas actuales de autorizacion por rol.
- Se recomienda endurecer CORS y eliminar fallbacks de prueba.

## 5. Brechas Para Un Cumplimiento Mas Alto

Para avanzar desde alineacion documental hacia un cumplimiento mas robusto, se recomienda:

- implementar politicas y middleware de autorizacion por rol en backend;
- registrar auditoria de eventos sensibles;
- formalizar plan de pruebas funcionales, de seguridad y regresion;
- definir control de cambios y versionado documental;
- establecer matriz de requisitos, casos de prueba y criterios de aceptacion;
- definir procedimientos de respaldo, recuperacion y continuidad operativa;
- formalizar manejo de vulnerabilidades y gestion de incidentes.

## 6. Conclusion

El proyecto queda documentado con una base formal y util para contextos academicos, tecnicos y de gestion. La carpeta creada sirve como punto de partida serio para alineacion con normas ISO/IEC, pero el cumplimiento total requiere evidencias adicionales de proceso, operacion, seguridad, prueba y gobierno del software.
