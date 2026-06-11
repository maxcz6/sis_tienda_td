CREATE DATABASE tienda_db;
USE tienda_db;

-- =====================================
-- TABLA: ROLES
-- =====================================

CREATE TABLE roles (
    id_rol INT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE
);

INSERT INTO roles VALUES
(1,'ADMINISTRADOR'),
(2,'CAJERO'),
(3,'ALMACENERO');

-- =====================================
-- TABLA: USUARIOS
-- =====================================

CREATE TABLE usuarios (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,

    nombres VARCHAR(150) NOT NULL,

    username VARCHAR(50) NOT NULL UNIQUE,

    password VARCHAR(255) NOT NULL,

    estado BOOLEAN DEFAULT TRUE,

    id_rol INT NOT NULL,

    CONSTRAINT fk_usuario_rol
    FOREIGN KEY (id_rol)
    REFERENCES roles(id_rol)
);

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

    id_cliente INT NOT NULL,

    id_tipo_comprobante INT NOT NULL,

    id_usuario INT NOT NULL,

    CONSTRAINT fk_venta_cliente
    FOREIGN KEY (id_cliente)
    REFERENCES clientes(id_cliente),

    CONSTRAINT fk_venta_tipo
    FOREIGN KEY (id_tipo_comprobante)
    REFERENCES tipo_comprobante(id_tipo_comprobante),

    CONSTRAINT fk_venta_usuario
    FOREIGN KEY (id_usuario)
    REFERENCES usuarios(id_usuario)
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

    id_usuario INT NOT NULL,

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
    REFERENCES motivos_movimiento(id_motivo),

    CONSTRAINT fk_movimiento_usuario
    FOREIGN KEY (id_usuario)
    REFERENCES usuarios(id_usuario)
);

-- =====================================
-- BOLETA / FACTURA
-- =====================================

SELECT

    -- DATOS DE LA VENTA
    v.id_venta,
    v.numero_comprobante,
    v.fecha_venta,

    -- TIPO DE COMPROBANTE
    tc.nombre AS tipo_comprobante,

    -- CLIENTE
    c.nombres AS cliente,
    c.dni_ruc,
    c.direccion,
    c.telefono,

    -- USUARIO / CAJERO
    u.nombres AS cajero,
    r.nombre AS rol,

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

INNER JOIN usuarios u
    ON v.id_usuario = u.id_usuario

INNER JOIN roles r
    ON u.id_rol = r.id_rol

INNER JOIN tipo_comprobante tc
    ON v.id_tipo_comprobante = tc.id_tipo_comprobante

INNER JOIN detalle_venta dv
    ON v.id_venta = dv.id_venta

INNER JOIN productos p
    ON dv.id_producto = p.id_producto

WHERE v.id_venta = 1;

-- =====================================
-- DATOS
-- =====================================

USE tienda_db;

-- =====================================
-- USUARIOS
-- =====================================

INSERT INTO usuarios (
    nombres,
    username,
    password,
    estado,
    id_rol
)
VALUES
('Administrador General', 'admin', 'admin123', TRUE, 1),
('Carlos Cajero', 'cajero1', '123456', TRUE, 2),
('Luis Almacenero', 'almacen1', '123456', TRUE, 3);

-- =====================================
-- CATEGORÍAS
-- =====================================

INSERT INTO categorias (nombre, descripcion) VALUES 
('Abarrotes', 'Productos básicos de canasta familiar'),
('Bebidas y Gaseosas', 'Gaseosas, aguas y jugos'),
('Lácteos y Embutidos', 'Leches, quesos y yogures');

-- =====================================
-- PRODUCTOS
-- =====================================

INSERT INTO productos (
    codigo_barras,
    nombre,
    descripcion,
    stock_actual,
    stock_minimo,
    precio_compra,
    precio_venta,
    estado,
    id_categoria
)
VALUES
('775012345601', 'Arroz Extra Costeño 1kg', 'Bolsa de arroz extra', 50, 10, 3.20, 3.90, TRUE, 1),

('775098765402', 'Gaseosa Inka Kola 3L', 'Botella no retornable', 24, 6, 8.50, 11.00, TRUE, 2),

('775123456703', 'Leche Gloria Azul 395g', 'Tarro de leche entera', 48, 12, 3.40, 4.20, TRUE, 3);

-- =====================================
-- CLIENTES
-- =====================================

INSERT INTO clientes (
    nombres,
    dni_ruc,
    direccion,
    telefono
)
VALUES 
('Juan Pérez Gómez', '45678912', 'Av. Las Flores 450', '987654321'),

('Distribuidora Los Andes S.A.C.', '20123456789', 'Jr. Ayacucho 123', '955112233'),

('María Huamán Rojas', '10456789123', 'Pmo. San Carlos Mz B Lote 4', '944887766');

-- =====================================
-- VENTAS
-- =====================================

INSERT INTO ventas (
    numero_comprobante,
    fecha_venta,
    subtotal,
    igv,
    total,
    id_cliente,
    id_tipo_comprobante,
    id_usuario
)
VALUES
(
'B001-000001',
'2026-05-15 09:30:00',
7.80,
0.00,
7.80,
1,
1,
2
),

(
'F001-000001',
'2026-05-15 10:15:00',
18.64,
3.36,
22.00,
2,
2,
2
),

(
'B001-000002',
'2026-05-15 11:00:00',
4.20,
0.00,
4.20,
3,
1,
2
);

-- =====================================
-- DETALLE VENTA
-- =====================================

INSERT INTO detalle_venta (
    id_venta,
    id_producto,
    cantidad,
    precio_unitario,
    subtotal
)
VALUES
(1, 1, 2, 3.90, 7.80),

(2, 2, 2, 11.00, 22.00),

(3, 3, 1, 4.20, 4.20);

-- =====================================
-- MOVIMIENTOS INVENTARIO
-- =====================================

INSERT INTO movimientos_inventario (
    id_producto,
    id_motivo,
    id_usuario,
    tipo_movimiento,
    cantidad,
    stock_anterior,
    stock_nuevo,
    observaciones
)
VALUES
(
1,
1,
3,
'ENTRADA',
52,
0,
52,
'Carga inicial por compra'
),

(
1,
2,
2,
'SALIDA',
2,
52,
50,
'Salida por Venta B001-000001'
),

(
2,
2,
2,
'SALIDA',
2,
26,
24,
'Salida por Venta F001-000001'
);