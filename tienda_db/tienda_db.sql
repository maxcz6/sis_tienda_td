-- wvhL7aLWIkyqkYfn
CREATE DATABASE tienda_db;
USE tienda_db;

-- =====================================
-- TABLA: categorias
-- =====================================

CREATE TABLE categorias (
    id_categoria INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion VARCHAR(255)
);

-- =====================================
-- TABLA: productos
-- =====================================

CREATE TABLE productos (
    id_producto INT AUTO_INCREMENT PRIMARY KEY,

    codigo_barras VARCHAR(50) UNIQUE,

    nombre VARCHAR(150) NOT NULL,

    descripcion TEXT,

    stock_actual INT DEFAULT 0,

    stock_minimo INT DEFAULT 5,

    precio_compra DECIMAL(10,2) NOT NULL,

    precio_venta DECIMAL(10,2) NOT NULL,

    estado BOOLEAN DEFAULT TRUE,

    id_categoria INT NOT NULL,

    CONSTRAINT fk_producto_categoria
    FOREIGN KEY (id_categoria)
    REFERENCES categorias(id_categoria)
);

-- =====================================
-- TABLA: clientes
-- =====================================

CREATE TABLE clientes (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,

    nombres VARCHAR(150) NOT NULL,

    dni_ruc VARCHAR(20),

    direccion VARCHAR(255),

    telefono VARCHAR(20)
);

-- =====================================
-- TABLA: tipo_comprobante
-- =====================================

CREATE TABLE tipo_comprobante (
    id_tipo_comprobante INT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL
);

INSERT INTO tipo_comprobante VALUES
(1,'BOLETA'),
(2,'FACTURA');

-- =====================================
-- TABLA: ventas
-- =====================================

CREATE TABLE ventas (
    id_venta INT AUTO_INCREMENT PRIMARY KEY,

    numero_comprobante VARCHAR(30) UNIQUE NOT NULL,

    fecha_venta DATETIME DEFAULT CURRENT_TIMESTAMP,

    subtotal DECIMAL(10,2) NOT NULL,

    igv DECIMAL(10,2) NOT NULL,

    total DECIMAL(10,2) NOT NULL,

    id_cliente INT,

    id_tipo_comprobante INT NOT NULL,

    CONSTRAINT fk_venta_cliente
    FOREIGN KEY (id_cliente)
    REFERENCES clientes(id_cliente),

    CONSTRAINT fk_venta_tipo
    FOREIGN KEY (id_tipo_comprobante)
    REFERENCES tipo_comprobante(id_tipo_comprobante)
);

-- =====================================
-- TABLA: detalle_venta
-- =====================================

CREATE TABLE detalle_venta (
    id_detalle INT AUTO_INCREMENT PRIMARY KEY,

    id_venta INT NOT NULL,

    id_producto INT NOT NULL,

    cantidad INT NOT NULL,

    precio_unitario DECIMAL(10,2) NOT NULL,

    subtotal DECIMAL(10,2) NOT NULL,

    CONSTRAINT fk_detalle_venta
    FOREIGN KEY (id_venta)
    REFERENCES ventas(id_venta),

    CONSTRAINT fk_detalle_producto
    FOREIGN KEY (id_producto)
    REFERENCES productos(id_producto)
);

-- =====================================
-- TABLA: motivos_movimiento
-- =====================================

CREATE TABLE motivos_movimiento (
    id_motivo INT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL
);

INSERT INTO motivos_movimiento VALUES
(1,'Compra'),
(2,'Venta'),
(3,'Ajuste'),
(4,'Producto roto');

-- =====================================
-- TABLA: movimientos_inventario
-- =====================================

CREATE TABLE movimientos_inventario (
    id_movimiento INT AUTO_INCREMENT PRIMARY KEY,

    id_producto INT NOT NULL,

    id_motivo INT NOT NULL,

    tipo_movimiento ENUM('ENTRADA','SALIDA') NOT NULL,

    cantidad INT NOT NULL,

    stock_anterior INT NOT NULL,

    stock_nuevo INT NOT NULL,

    fecha_movimiento DATETIME DEFAULT CURRENT_TIMESTAMP,

    observaciones TEXT,

    CONSTRAINT fk_movimiento_producto
    FOREIGN KEY (id_producto)
    REFERENCES productos(id_producto),

    CONSTRAINT fk_movimiento_motivo
    FOREIGN KEY (id_motivo)
    REFERENCES motivos_movimiento(id_motivo)
);
-- BOLETA FACTURA 
SELECT

    -- DATOS DE LA VENTA
    v.id_venta,
    v.numero_comprobante,
    v.fecha_venta,

    -- TIPO DE COMPROBANTE
    tc.nombre AS tipo_comprobante,

    -- DATOS DEL CLIENTE
    c.nombres AS cliente,
    c.dni_ruc,
    c.direccion,
    c.telefono,

    -- PRODUCTOS
    p.nombre AS producto,
    dv.cantidad,
    dv.precio_unitario,
    dv.subtotal,

    -- TOTALES
    v.subtotal AS subtotal_venta,
    v.igv,
    v.total

FROM ventas v

INNER JOIN clientes c
    ON v.id_cliente = c.id_cliente

INNER JOIN tipo_comprobante tc
    ON v.id_tipo_comprobante = tc.id_tipo_comprobante

INNER JOIN detalle_venta dv
    ON v.id_venta = dv.id_venta

INNER JOIN productos p
    ON dv.id_producto = p.id_producto

WHERE v.id_venta = 1;

-- DATOS

USE tienda_db;

-- 1. INSERTAR CATEGORÍAS
-- (Genera id_categoria: 1, 2, 3)
INSERT INTO categorias (nombre, descripcion) VALUES 
('Abarrotes', 'Productos básicos de canasta familiar, arroz, azúcar, aceite'), 
('Bebidas y Gaseosas', 'Gaseosas, aguas de mesa, jugos y rehidratantes'), 
('Lácteos y Embutidos', 'Leche, quesos, yogures y embutidos en general');


-- 2. INSERTAR PRODUCTOS
-- (Se enlazan a las categorías 1, 2 y 3 creadas arriba)
INSERT INTO productos (codigo_barras, nombre, descripcion, stock_actual, stock_minimo, precio_compra, precio_venta, estado, id_categoria) VALUES
('775012345601', 'Arroz Extra Costeño 1kg', 'Bolsa de arroz extra', 50, 10, 3.20, 3.90, TRUE, 1),
('775098765402', 'Gaseosa Inka Kola 3L', 'Botella no retornable', 24, 6, 8.50, 11.00, TRUE, 2),
('775123456703', 'Leche Evaporada Gloria Azul 395g', 'Tarro de leche entera', 48, 12, 3.40, 4.20, TRUE, 3);


-- 3. INSERTAR CLIENTES
-- (Genera id_cliente: 1, 2, 3)
INSERT INTO clientes (nombres, dni_ruc, direccion, telefono) VALUES 
('Juan Pérez Gómez', '45678912', 'Av. Las Flores 450', '987654321'), 
('Distribuidora Los Andes S.A.C.', '20123456789', 'Jr. Ayacucho 123', '955112233'), 
('María Huamán Rojas', '10456789123', 'Pmo. San Carlos Mz B Lote 4', '944887766');


-- 4. INSERTAR VENTAS
-- Nota: En Perú el IGV es el 18%. El cálculo es: Total = Subtotal + IGV.
INSERT INTO ventas (numero_comprobante, fecha_venta, subtotal, igv, total, id_cliente, id_tipo_comprobante) VALUES
('B001-000001', '2026-05-15 09:30:00', 7.80, 0.00, 7.80, 1, 1),  -- Boleta (Frecuentemente no desglosa IGV o el cliente es usuario final, total neto)
('F001-000001', '2026-05-15 10:15:00', 18.64, 3.36, 22.00, 2, 2), -- Factura (Subtotal 18.64 + IGV 3.36 = Total 22.00)
('B001-000002', '2026-05-15 11:00:00', 4.20, 0.00, 4.20, 3, 1);  -- Boleta


-- 5. INSERTAR DETALLE DE VENTA
-- (Vincula los productos vendidos con los subtotales de las ventas)
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario, subtotal) VALUES
(1, 1, 2, 3.90, 7.80),   -- Venta 1: 2 bolsas de Arroz (2 * 3.90 = 7.80)
(2, 2, 2, 11.00, 22.00), -- Venta 2: 2 botellas de Inka Kola (2 * 11.00 = 22.00)
(3, 3, 1, 4.20, 4.20);   -- Venta 3: 1 tarro de Leche Gloria (1 * 4.20 = 4.20)


-- 6. INSERTAR MOVIMIENTOS DE INVENTARIO
-- (Simula el historial de ingresos por compra y salidas por las ventas anteriores)
INSERT INTO movimientos_inventario (id_producto, id_motivo, tipo_movimiento, cantidad, stock_anterior, stock_nuevo, observaciones) VALUES
(1, 1, 'ENTRADA', 52, 0, 52, 'Carga inicial por compra a distribuidor'),
(1, 2, 'SALIDA', 2, 52, 50, 'Salida por Venta - Comprobante B001-000001'),
(2, 2, 'SALIDA', 2, 26, 24, 'Salida por Venta - Comprobante F001-000001');