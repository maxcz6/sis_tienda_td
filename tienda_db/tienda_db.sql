-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.roles (
  id_rol integer NOT NULL,
  nombre character varying NOT NULL UNIQUE,
  CONSTRAINT roles_pkey PRIMARY KEY (id_rol)
);
CREATE TABLE public.usuarios (
  id_usuario bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  nombres character varying NOT NULL,
  username character varying NOT NULL UNIQUE,
  password character varying NOT NULL,
  estado boolean DEFAULT true,
  id_rol integer NOT NULL,
  CONSTRAINT usuarios_pkey PRIMARY KEY (id_usuario),
  CONSTRAINT fk_usuario_rol FOREIGN KEY (id_rol) REFERENCES public.roles(id_rol)
);
CREATE TABLE public.categorias (
  id_categoria bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  nombre character varying NOT NULL,
  descripcion character varying,
  CONSTRAINT categorias_pkey PRIMARY KEY (id_categoria)
);
CREATE TABLE public.productos (
  id_producto bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  codigo_barras character varying UNIQUE,
  nombre character varying NOT NULL,
  descripcion text,
  stock_actual integer DEFAULT 0,
  stock_minimo integer DEFAULT 5,
  precio_compra numeric NOT NULL,
  precio_venta numeric NOT NULL,
  estado boolean DEFAULT true,
  id_categoria bigint NOT NULL,
  CONSTRAINT productos_pkey PRIMARY KEY (id_producto),
  CONSTRAINT fk_producto_categoria FOREIGN KEY (id_categoria) REFERENCES public.categorias(id_categoria)
);
CREATE TABLE public.clientes (
  id_cliente bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  nombres character varying NOT NULL,
  dni_ruc character varying,
  direccion character varying,
  telefono character varying,
  CONSTRAINT clientes_pkey PRIMARY KEY (id_cliente)
);
CREATE TABLE public.tipo_comprobante (
  id_tipo_comprobante integer NOT NULL,
  nombre character varying NOT NULL,
  CONSTRAINT tipo_comprobante_pkey PRIMARY KEY (id_tipo_comprobante)
);
CREATE TABLE public.ventas (
  id_venta bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  numero_comprobante character varying NOT NULL UNIQUE,
  fecha_venta timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  subtotal numeric NOT NULL,
  igv numeric NOT NULL,
  total numeric NOT NULL,
  id_cliente bigint NOT NULL,
  id_tipo_comprobante integer NOT NULL,
  id_usuario bigint NOT NULL,
  CONSTRAINT ventas_pkey PRIMARY KEY (id_venta),
  CONSTRAINT fk_venta_cliente FOREIGN KEY (id_cliente) REFERENCES public.clientes(id_cliente),
  CONSTRAINT fk_venta_tipo FOREIGN KEY (id_tipo_comprobante) REFERENCES public.tipo_comprobante(id_tipo_comprobante),
  CONSTRAINT fk_venta_usuario FOREIGN KEY (id_usuario) REFERENCES public.usuarios(id_usuario)
);
CREATE TABLE public.detalle_venta (
  id_detalle bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  id_venta bigint NOT NULL,
  id_producto bigint NOT NULL,
  cantidad integer NOT NULL,
  precio_unitario numeric NOT NULL,
  subtotal numeric NOT NULL,
  CONSTRAINT detalle_venta_pkey PRIMARY KEY (id_detalle),
  CONSTRAINT fk_detalle_venta FOREIGN KEY (id_venta) REFERENCES public.ventas(id_venta),
  CONSTRAINT fk_detalle_producto FOREIGN KEY (id_producto) REFERENCES public.productos(id_producto)
);
CREATE TABLE public.motivos_movimiento (
  id_motivo integer NOT NULL,
  nombre character varying NOT NULL,
  CONSTRAINT motivos_movimiento_pkey PRIMARY KEY (id_motivo)
);
CREATE TABLE public.movimientos_inventario (
  id_movimiento bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  id_producto bigint NOT NULL,
  id_motivo integer NOT NULL,
  id_usuario bigint NOT NULL,
  tipo_movimiento USER-DEFINED NOT NULL,
  cantidad integer NOT NULL,
  stock_anterior integer NOT NULL,
  stock_nuevo integer NOT NULL,
  fecha_movimiento timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  observaciones text,
  CONSTRAINT movimientos_inventario_pkey PRIMARY KEY (id_movimiento),
  CONSTRAINT fk_movimiento_producto FOREIGN KEY (id_producto) REFERENCES public.productos(id_producto),
  CONSTRAINT fk_movimiento_motivo FOREIGN KEY (id_motivo) REFERENCES public.motivos_movimiento(id_motivo),
  CONSTRAINT fk_movimiento_usuario FOREIGN KEY (id_usuario) REFERENCES public.usuarios(id_usuario)
);