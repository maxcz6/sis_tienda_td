# Logica De Negocio De La API

## 1. Proposito

Este documento describe las reglas funcionales implementadas en la API que representan el comportamiento del negocio de `TiendaTodo`.

## 2. Reglas De Autenticacion

- El usuario debe proporcionar credenciales validas para iniciar sesion.
- El sistema intenta autenticar contra la base local.
- Si el usuario no existe localmente, la API puede consultar Supabase para recuperarlo y registrarlo localmente.
- La compatibilidad actual contempla contrasenas en hash Laravel y, temporalmente, contrasenas heredadas en texto plano.
- Al autenticar correctamente, el sistema emite un token de acceso.

## 3. Reglas De Roles

Roles base observados:

- `1`: Administrador
- `2`: Cajero
- `3`: Almacenero

Regla actual:

- La restriccion por rol se usa principalmente en frontend.
- La API autentica, pero no aplica aun una matriz completa de autorizacion por politica.

Implicacion:

- Debe considerarse una mejora prioritaria para cerrar brechas de seguridad y cumplimiento.

## 4. Reglas De Categorias

- Una categoria puede crearse, editarse, listarse y eliminarse.
- Una categoria no debe eliminarse si tiene productos asociados.
- La integridad referencial se protege evitando perdida de catalogos en uso.

## 5. Reglas De Clientes

- Un cliente puede registrarse, actualizarse, consultarse y eliminarse.
- Un cliente no debe eliminarse si posee ventas registradas.
- Esta regla preserva trazabilidad comercial y consistencia historica.

## 6. Reglas De Productos

- Todo producto pertenece a una categoria valida.
- Al crear un producto, el sistema define valores por defecto para stock inicial, stock minimo y estado.
- Un producto inactivo no puede ser vendido.
- El listado de bajo stock se determina cuando `stock_actual <= stock_minimo`.
- Si un producto tiene historial de ventas o movimientos, su eliminacion se resuelve mediante desactivacion logica en lugar de borrado fisico.

## 7. Reglas De Ventas

### 7.1 Validaciones Previas

- Toda venta requiere cliente valido.
- Toda venta requiere tipo de comprobante valido.
- Toda venta debe contener al menos un item.
- Cada item debe referenciar un producto existente.
- Cada item debe tener cantidad entera positiva.

### 7.2 Reglas Transaccionales

- El registro de venta se ejecuta dentro de una transaccion.
- Si un solo item falla, la venta completa debe revertirse.
- El sistema valida que cada producto este activo antes de venderlo.
- El sistema valida stock suficiente antes de confirmar la operacion.

### 7.3 Reglas De Comprobante

- Para boleta se usa correlativo con prefijo `B001`.
- Para factura se usa correlativo con prefijo `F001`.
- El correlativo se incrementa secuencialmente por tipo de comprobante.

### 7.4 Reglas De Calculo

- El total general es la suma de subtotales por item.
- Si el comprobante es factura, el sistema desglosa IGV calculando subtotal y tributo sobre el total.
- Si el comprobante es boleta, el total se conserva neto y el IGV se reporta en cero segun implementacion actual.

### 7.5 Reglas De Persistencia

- Se registra cabecera de venta.
- Se registran detalles de venta por item.
- Se descuenta stock por cada producto vendido.
- Se genera un movimiento de inventario tipo `SALIDA` por cada item.
- El movimiento registra stock anterior, stock nuevo, usuario y observacion.

## 8. Reglas De Inventario

### 8.1 Registro De Movimientos

- Todo movimiento requiere producto valido.
- Todo movimiento requiere motivo valido.
- El tipo de movimiento solo puede ser `ENTRADA` o `SALIDA`.
- La cantidad debe ser entera positiva.

### 8.2 Reglas De Stock

- Una entrada incrementa el stock actual.
- Una salida reduce el stock actual.
- No se permite una salida si el stock disponible es menor que la cantidad solicitada.
- Todo cambio de stock debe registrar estado anterior y estado resultante.

### 8.3 Trazabilidad

- Cada movimiento se asocia a producto, motivo, usuario, fecha y observaciones.
- La consulta historica admite filtrado por producto, tipo y motivo.

## 9. Reglas De Usuarios

- Un usuario pertenece a un rol.
- La contrasena se almacena con hash al crear o actualizar registros desde mantenimiento.
- El usuario administrador principal no debe eliminarse.
- Si un usuario tiene historial operativo, su baja se resuelve mediante desactivacion logica en vez de borrado fisico.

## 10. Reglas Del Dashboard

El dashboard consolida:

- ventas del dia,
- cantidad de productos activos,
- productos con bajo stock,
- tendencia de ventas recientes,
- productos mas vendidos,
- alertas operativas.

Estas metricas soportan supervision y toma de decisiones diaria.

## 11. Reglas De Sincronizacion

- Los modelos integrados con Supabase intentan sincronizarse al guardar o eliminar.
- Si la sincronizacion inmediata falla, el registro se encola.
- La cola conserva intentos y estado del proceso.
- Existe procesamiento periodico y disparo manual de sincronizacion.

## 12. Excepciones Temporales Detectadas

- En ventas, si no existe usuario autenticado, se usa un `id_usuario` de respaldo para pruebas.
- En inventario, si no existe usuario autenticado, se usa un `id_usuario` de respaldo para pruebas.

Estas excepciones deben removerse o aislarse por entorno antes de liberar a produccion.

## 13. Implicaciones Para Cumplimiento Y Calidad

Desde la perspectiva de ingenieria, las reglas actuales favorecen:

- integridad transaccional,
- trazabilidad operativa,
- consistencia historica,
- separacion razonable entre interfaz y backend.

Sin embargo, para elevar el nivel de cumplimiento se recomienda:

- implementar autorizacion por rol en backend,
- normalizar politicas de error y auditoria,
- eliminar fallbacks de pruebas en produccion,
- formalizar pruebas automatizadas por proceso critico.
