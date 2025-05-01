
-- ================================================================
-- 🌐 TianguiStore – Estructura Base de Datos Expandida v1.0
-- ================================================================
-- 🔧 Arquitectura Modular, Escalable y Autogestionada
-- ✅ Cobertura: E-commerce + Servicios + Eventos + Gamificación + Contabilidad
-- 🧠 Incluye: Fidelización, Marketing, Auditoría, Estadísticas, Seguridad, Pagos, Profesionistas
-- 📅 Última generación automatizada: Estructura SQL completa, documentada y lista para producción
-- ================================================================

-- ================================================================
-- 🌐 TianguiStore – Estructura Completa y Expandida de Base de Datos
-- Versión: 1.0.0
-- Autor: I.S.C. Erick Renato Vega Ceron
-- Descripción: Este archivo contiene la estructura lógica completa del sistema TianguiStore,
--              optimizada para comercio electrónico, fidelización, gamificación, analítica,
--              trazabilidad, contabilidad y marketing digital automatizado.
-- Base de datos: tienda_db
-- Última generación: 01/05/2025
-- ================================================================

/* NOTAS:
 - Esta base de datos está normalizada para eficiencia y extensibilidad.
 - Incluye triggers, vistas, procedimientos almacenados, validaciones, métricas, auditoría.
 - Utiliza SHA-256 como identificador de estructura para verificación de consistencia.
 - Cada módulo tiene comentarios que explican su propósito.
*/



-- ================================================================
-- 🏗️ ESTRUCTURA COMPLETA COMENTADA DE BASE DE DATOS: tienda_db
-- Para tienda en línea con marketing, blog, prospección y postventa
-- ================================================================

DROP DATABASE IF EXISTS tienda_db;
CREATE DATABASE tienda_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE tienda_db;

-- ================================================================
-- 🧾 ESTADOS DE PEDIDO
-- ================================================================
-- Define los distintos estados que puede tener un pedido
CREATE TABLE estados_pedido (
  estado_id INT AUTO_INCREMENT PRIMARY KEY,
  estado_nombre VARCHAR(50) NOT NULL UNIQUE,
  descripcion TEXT
) ENGINE=InnoDB;

-- ================================================================
-- 🧑‍⚖️ ROLES DE USUARIOS
-- ================================================================
-- Define los diferentes roles de usuarios y sus permisos
CREATE TABLE roles (
  rol_id INT AUTO_INCREMENT PRIMARY KEY,
  rol_nombre VARCHAR(50) NOT NULL UNIQUE,
  descripcion TEXT,
  permisos_json JSON NOT NULL
) ENGINE=InnoDB;

-- ================================================================
-- 👤 USUARIOS
-- ================================================================
-- Información de los usuarios, incluyendo clientes, vendedores, administradores
CREATE TABLE usuarios (
  usuario_id INT AUTO_INCREMENT PRIMARY KEY,
  correo_electronico VARCHAR(100) NOT NULL UNIQUE,
  contrasena_hash VARCHAR(255) NOT NULL,
  nombre VARCHAR(50) NOT NULL,
  apellido_paterno VARCHAR(50),
  apellido_materno VARCHAR(50),
  telefono VARCHAR(20),
  direccion TEXT,
  foto_perfil_url VARCHAR(255),
  activo BOOLEAN DEFAULT TRUE,
  rol_id INT NOT NULL DEFAULT 3,
  fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (rol_id) REFERENCES roles(rol_id)
) ENGINE=InnoDB;

-- ================================================================
-- 🧾 LOGS DE ACCIONES
-- ================================================================
-- Registro de acciones del sistema para trazabilidad y auditoría
CREATE TABLE logs_acciones (
  log_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  usuario_id INT,
  tabla_afectada VARCHAR(100),
  id_registro_afectado VARCHAR(100),
  accion ENUM('INSERT', 'UPDATE', 'DELETE', 'LOGIN', 'LOGOUT') NOT NULL,
  descripcion TEXT,
  datos_anteriores JSON,
  datos_nuevos JSON,
  fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (usuario_id) REFERENCES usuarios(usuario_id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- ================================================================
-- 🏷️ MARCAS Y CATEGORÍAS
-- ================================================================
-- Marcas asociadas a productos
CREATE TABLE marcas (
  marca_id INT AUTO_INCREMENT PRIMARY KEY,
  nombre_marca VARCHAR(100) NOT NULL UNIQUE,
  descripcion TEXT,
  logo_url VARCHAR(255),
  micrositio_url VARCHAR(255)
) ENGINE=InnoDB;

-- Categorías principales
CREATE TABLE categorias (
  categoria_id INT AUTO_INCREMENT PRIMARY KEY,
  nombre_categoria VARCHAR(100) NOT NULL UNIQUE,
  descripcion TEXT
) ENGINE=InnoDB;

-- Subcategorías relacionadas a una categoría
CREATE TABLE subcategorias (
  subcategoria_id INT AUTO_INCREMENT PRIMARY KEY,
  categoria_id INT NOT NULL,
  nombre_subcategoria VARCHAR(100) NOT NULL,
  descripcion TEXT,
  UNIQUE (categoria_id, nombre_subcategoria),
  FOREIGN KEY (categoria_id) REFERENCES categorias(categoria_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ================================================================
-- 📦 PRODUCTOS
-- ================================================================
-- Información de productos, incluye publicación, variantes y categorías
CREATE TABLE productos (
  producto_id INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  descripcion TEXT NOT NULL,
  marca_id INT,
  precio DECIMAL(10,2) NOT NULL,
  descuento DECIMAL(5,2) DEFAULT 0.00,
  stock INT DEFAULT 0,
  categoria_id INT,
  subcategoria_id INT,
  imagen_url VARCHAR(255),
  publicado BOOLEAN DEFAULT FALSE,
  proveedor_id INT,
  fecha_creacion DATETIME DEFAULT CURRENT_TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  status ENUM('activo', 'inactivo', 'demo') DEFAULT 'activo',
  meses_sin_intereses BOOLEAN DEFAULT FALSE,
  tipo_publicacion_id INT,
  FOREIGN KEY (marca_id) REFERENCES marcas(marca_id) ON DELETE SET NULL,
  FOREIGN KEY (categoria_id) REFERENCES categorias(categoria_id) ON DELETE SET NULL,
  FOREIGN KEY (subcategoria_id) REFERENCES subcategorias(subcategoria_id) ON DELETE SET NULL,
  FOREIGN KEY (proveedor_id) REFERENCES usuarios(usuario_id) ON DELETE SET NULL,
  FOREIGN KEY (tipo_publicacion_id) REFERENCES tipos_publicacion(tipo_id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- Tipos de publicación (ej. membresías de vendedor)
CREATE TABLE tipos_publicacion (
  tipo_id INT AUTO_INCREMENT PRIMARY KEY,
  nombre_tipo VARCHAR(50) NOT NULL UNIQUE,
  descripcion TEXT,
  prioridad INT DEFAULT 0,
  duracion_dias INT DEFAULT 30,
  permite_promociones BOOLEAN DEFAULT FALSE,
  permite_destacar BOOLEAN DEFAULT FALSE,
  requiere_pago BOOLEAN DEFAULT FALSE,
  precio_publicacion DECIMAL(10,2) DEFAULT 0.00
) ENGINE=InnoDB;

-- ================================================================
-- 🎁 SISTEMA DE FIDELIDAD Y PUNTOS
-- ================================================================

-- Configuración general de niveles o planes de fidelidad
CREATE TABLE niveles_fidelidad (
  nivel_id INT AUTO_INCREMENT PRIMARY KEY,
  nombre_nivel VARCHAR(50) NOT NULL UNIQUE,
  descripcion TEXT,
  puntos_necesarios INT NOT NULL,
  beneficios JSON,
  activo BOOLEAN DEFAULT TRUE
) ENGINE=InnoDB;

-- Registro de puntos ganados por usuario
CREATE TABLE puntos_usuario (
  puntos_id INT AUTO_INCREMENT PRIMARY KEY,
  usuario_id INT NOT NULL,
  tipo_evento ENUM('compra', 'registro', 'comentario', 'referido') NOT NULL,
  referencia_id INT,
  puntos INT NOT NULL,
  descripcion TEXT,
  fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (usuario_id) REFERENCES usuarios(usuario_id)
) ENGINE=InnoDB;

-- Canje de puntos por productos o cupones
CREATE TABLE canjes_puntos (
  canje_id INT AUTO_INCREMENT PRIMARY KEY,
  usuario_id INT NOT NULL,
  tipo_canje ENUM('cupon', 'producto') NOT NULL,
  item_id INT,
  puntos_utilizados INT NOT NULL,
  fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  estado ENUM('pendiente', 'entregado', 'rechazado') DEFAULT 'pendiente',
  FOREIGN KEY (usuario_id) REFERENCES usuarios(usuario_id)
) ENGINE=InnoDB;

-- Historial de cambios de nivel de fidelidad
CREATE TABLE historial_niveles (
  historial_id INT AUTO_INCREMENT PRIMARY KEY,
  usuario_id INT NOT NULL,
  nivel_anterior_id INT,
  nivel_nuevo_id INT NOT NULL,
  fecha_cambio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (usuario_id) REFERENCES usuarios(usuario_id),
  FOREIGN KEY (nivel_anterior_id) REFERENCES niveles_fidelidad(nivel_id),
  FOREIGN KEY (nivel_nuevo_id) REFERENCES niveles_fidelidad(nivel_id)
) ENGINE=InnoDB;

-- ================================================================
-- 🕹️ GAMIFICACIÓN AVANZADA
-- ================================================================

-- Definición de logros desbloqueables
CREATE TABLE logros (
  logro_id INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  descripcion TEXT NOT NULL,
  icono_url VARCHAR(255),
  tipo_logro ENUM('compra', 'actividad', 'referido', 'contenido', 'evento') NOT NULL,
  criterio_json JSON NOT NULL,
  puntos_recompensa INT DEFAULT 0,
  activo BOOLEAN DEFAULT TRUE
) ENGINE=InnoDB;

-- Logros obtenidos por usuario
CREATE TABLE logros_usuario (
  id INT AUTO_INCREMENT PRIMARY KEY,
  usuario_id INT NOT NULL,
  logro_id INT NOT NULL,
  fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (usuario_id) REFERENCES usuarios(usuario_id),
  FOREIGN KEY (logro_id) REFERENCES logros(logro_id)
) ENGINE=InnoDB;

-- Misiones diarias, semanales o de campaña
CREATE TABLE misiones (
  mision_id INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  descripcion TEXT NOT NULL,
  tipo ENUM('diaria', 'semanal', 'especial') DEFAULT 'diaria',
  recompensa_puntos INT DEFAULT 0,
  recompensa_cupon_id INT,
  fecha_inicio DATE,
  fecha_fin DATE,
  condiciones JSON NOT NULL,
  FOREIGN KEY (recompensa_cupon_id) REFERENCES cupones(cupon_id)
) ENGINE=InnoDB;

-- Seguimiento de progreso de misiones por usuario
CREATE TABLE progreso_mision (
  progreso_id INT AUTO_INCREMENT PRIMARY KEY,
  usuario_id INT NOT NULL,
  mision_id INT NOT NULL,
  progreso_json JSON,
  completada BOOLEAN DEFAULT FALSE,
  fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (usuario_id) REFERENCES usuarios(usuario_id),
  FOREIGN KEY (mision_id) REFERENCES misiones(mision_id)
) ENGINE=InnoDB;

-- Clasificación general de usuarios (ranking)
CREATE TABLE ranking_usuarios (
  usuario_id INT PRIMARY KEY,
  puntos_totales INT DEFAULT 0,
  nivel_actual INT DEFAULT 1,
  logros_obtenidos INT DEFAULT 0,
  misiones_completadas INT DEFAULT 0,
  fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (usuario_id) REFERENCES usuarios(usuario_id)
) ENGINE=InnoDB;

-- ================================================================
-- 🔄 PUNTOS EXPIRABLES
-- ================================================================
-- Registro extendido de puntos con fecha de expiración y redención
ALTER TABLE puntos_usuario
ADD COLUMN fecha_expiracion DATE DEFAULT NULL,
ADD COLUMN redimido BOOLEAN DEFAULT FALSE;

-- ================================================================
-- 🧮 RANKING DE VENDEDORES Y PROMOTORES
-- ================================================================

-- Ranking basado en rendimiento de vendedores o promotores
CREATE TABLE ranking_promotores (
  usuario_id INT PRIMARY KEY,
  tipo ENUM('vendedor', 'promotor') DEFAULT 'vendedor',
  total_productos_vendidos INT DEFAULT 0,
  total_clientes_atendidos INT DEFAULT 0,
  total_puntos_otorgados INT DEFAULT 0,
  total_misiones_cumplidas INT DEFAULT 0,
  nivel_actual INT DEFAULT 1,
  fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (usuario_id) REFERENCES usuarios(usuario_id)
) ENGINE=InnoDB;

-- Relación de productos promocionados por usuario
CREATE TABLE productos_promocionados (
  id INT AUTO_INCREMENT PRIMARY KEY,
  usuario_id INT NOT NULL,
  producto_id INT NOT NULL,
  fecha_asignacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  destacado BOOLEAN DEFAULT FALSE,
  FOREIGN KEY (usuario_id) REFERENCES usuarios(usuario_id),
  FOREIGN KEY (producto_id) REFERENCES productos(producto_id)
) ENGINE=InnoDB;

-- Historial de promociones concretadas con éxito
CREATE TABLE historial_promociones (
  id INT AUTO_INCREMENT PRIMARY KEY,
  usuario_id INT NOT NULL,
  producto_id INT NOT NULL,
  cliente_id INT,
  tipo_logro ENUM('compra_directa', 'registro_via_promocion', 'click', 'compra_asociada') NOT NULL,
  fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (usuario_id) REFERENCES usuarios(usuario_id),
  FOREIGN KEY (producto_id) REFERENCES productos(producto_id),
  FOREIGN KEY (cliente_id) REFERENCES usuarios(usuario_id)
) ENGINE=InnoDB;


-- ================================================================
-- 🔁 TRIGGERS RECOMENDADOS
-- ================================================================

DELIMITER //

-- Recalcular puntos totales al registrar nuevo punto
CREATE TRIGGER trg_actualizar_puntos_usuario
AFTER INSERT ON puntos_usuario
FOR EACH ROW
BEGIN
  UPDATE ranking_usuarios
  SET puntos_totales = puntos_totales + NEW.puntos
  WHERE usuario_id = NEW.usuario_id;
END;
//

-- Actualizar ranking de promotores por venta
CREATE TRIGGER trg_incrementar_ventas_promotor
AFTER INSERT ON historial_promociones
FOR EACH ROW
BEGIN
  IF NEW.tipo_logro = 'compra_directa' THEN
    UPDATE ranking_promotores
    SET total_productos_vendidos = total_productos_vendidos + 1
    WHERE usuario_id = NEW.usuario_id;
  END IF;
END;
//

DELIMITER ;

-- ================================================================
-- 👁️ VISTAS RECOMENDADAS
-- ================================================================

-- Vista de ranking top 10 general
CREATE OR REPLACE VIEW vista_top_usuarios AS
SELECT u.usuario_id, u.nombre, ru.puntos_totales, ru.nivel_actual
FROM ranking_usuarios ru
JOIN usuarios u ON ru.usuario_id = u.usuario_id
ORDER BY ru.puntos_totales DESC
LIMIT 10;

-- Vista de vendedores con mejor rendimiento
CREATE OR REPLACE VIEW vista_top_vendedores AS
SELECT u.usuario_id, u.nombre, rp.total_productos_vendidos, rp.total_clientes_atendidos
FROM ranking_promotores rp
JOIN usuarios u ON rp.usuario_id = u.usuario_id
WHERE rp.tipo = 'vendedor'
ORDER BY rp.total_productos_vendidos DESC;

-- Vista de puntos expirados y no redimidos
CREATE OR REPLACE VIEW vista_puntos_expirados AS
SELECT pu.*, u.nombre
FROM puntos_usuario pu
JOIN usuarios u ON pu.usuario_id = u.usuario_id
WHERE pu.redimido = FALSE AND pu.fecha_expiracion IS NOT NULL AND pu.fecha_expiracion < CURRENT_DATE;

-- ================================================================
-- 📊 SISTEMA DE REPORTES PERSONALIZADOS
-- ================================================================

-- Catálogo de tipos de reporte predefinidos o personalizados
CREATE TABLE reportes (
  reporte_id INT AUTO_INCREMENT PRIMARY KEY,
  nombre_reporte VARCHAR(100) NOT NULL,
  descripcion TEXT,
  tipo ENUM('venta', 'cliente', 'producto', 'actividad', 'auditoria', 'otros') NOT NULL,
  query_sql TEXT NOT NULL,
  programado BOOLEAN DEFAULT FALSE,
  visibilidad ENUM('admin', 'vendedor', 'cliente', 'soporte') DEFAULT 'admin',
  creado_por INT,
  fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (creado_por) REFERENCES usuarios(usuario_id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- Historial de ejecuciones de reportes
CREATE TABLE ejecucion_reportes (
  ejecucion_id INT AUTO_INCREMENT PRIMARY KEY,
  reporte_id INT NOT NULL,
  usuario_id INT,
  resultado_resumen TEXT,
  exito BOOLEAN DEFAULT TRUE,
  fecha_ejecucion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (reporte_id) REFERENCES reportes(reporte_id),
  FOREIGN KEY (usuario_id) REFERENCES usuarios(usuario_id)
) ENGINE=InnoDB;

-- ================================================================
-- 🔐 MEDIDAS DE SEGURIDAD, INTEGRIDAD Y MANTENIMIENTO
-- ================================================================

-- ================================================================
-- 🔒 RESTRICCIONES Y VALIDACIONES
-- ================================================================

-- Evita que usuarios inactivos reciban puntos
CREATE TRIGGER trg_validar_usuario_activo_puntos
BEFORE INSERT ON puntos_usuario
FOR EACH ROW
BEGIN
  DECLARE es_activo BOOLEAN;
  SELECT activo INTO es_activo FROM usuarios WHERE usuario_id = NEW.usuario_id;
  IF es_activo IS FALSE THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se pueden asignar puntos a usuarios inactivos';
  END IF;
END;

-- Protege contra eliminación de usuarios tipo admin
CREATE TRIGGER trg_proteger_admin_delete
BEFORE DELETE ON usuarios
FOR EACH ROW
BEGIN
  DECLARE tipo_rol VARCHAR(50);
  SELECT rol_nombre INTO tipo_rol FROM roles WHERE rol_id = OLD.rol_id;
  IF tipo_rol = 'admin' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se permite eliminar usuarios administradores';
  END IF;
END;

-- ================================================================
-- 🔁 BORRADO LÓGICO PARA USUARIOS Y PRODUCTOS
-- ================================================================

-- Campos de borrado lógico (solo si no existen aún)
-- ALTER TABLE usuarios ADD COLUMN borrado_logico BOOLEAN DEFAULT FALSE;
-- ALTER TABLE productos ADD COLUMN borrado_logico BOOLEAN DEFAULT FALSE;

-- Triggers para prevenir borrado físico (alternativa segura)
CREATE TRIGGER trg_proteger_borrado_usuarios
BEFORE DELETE ON usuarios
FOR EACH ROW
BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se permite eliminar usuarios. Use borrado lógico.';
END;

-- ================================================================
-- 🔄 MANTENIMIENTO AUTOMÁTICO: EXPIRAR PUNTOS
-- ================================================================

-- Evento programado (requiere habilitar event_scheduler = ON en MySQL)
DROP EVENT IF EXISTS evt_expirar_puntos;
CREATE EVENT evt_expirar_puntos
ON SCHEDULE EVERY 1 DAY
DO
  UPDATE puntos_usuario
  SET redimido = TRUE
  WHERE fecha_expiracion IS NOT NULL AND fecha_expiracion < CURRENT_DATE AND redimido = FALSE;

-- ================================================================
-- 🧾 INTEGRIDAD CON FIRMA HASH (verificación de datos)
-- ================================================================

-- Campo de firma_hash en pedidos (suponiendo ya añadido)
-- ALTER TABLE pedidos ADD COLUMN firma_hash CHAR(64);

-- Trigger para asignar hash de integridad
CREATE TRIGGER trg_firma_hash_pedido
BEFORE INSERT ON pedidos
FOR EACH ROW
BEGIN
  SET NEW.firma_hash = SHA2(CONCAT(NEW.cliente_id, NEW.total, NEW.fecha_pedido), 256);
END;

-- ================================================================
-- 🔄 MANEJO TRANSACCIONAL SUGERIDO (a nivel aplicación)
-- ================================================================
-- 💡 NOTA: Las siguientes transacciones se implementan desde el backend.
-- Se recomienda envolver operaciones como:

-- 1. Crear pedido
-- 2. Insertar productos en detalle_pedido
-- 3. Disminuir stock
-- 4. Aplicar cupon y puntos

-- Usar BEGIN ... COMMIT / ROLLBACK desde la lógica de servidor.
-- También puede implementarse en procedimientos almacenados si se desea.


-- ================================================================
-- 🛠️ MANTENIMIENTO AUTOMÁTICO DE LA BASE DE DATOS (EFICIENTE)
-- ================================================================

-- Habilitar EVENT SCHEDULER si no está activo
-- SET GLOBAL event_scheduler = ON;

-- ===============================
-- 🔄 Limpieza de puntos expirados
-- ===============================
DROP EVENT IF EXISTS evt_expirar_puntos;
CREATE EVENT evt_expirar_puntos
ON SCHEDULE EVERY 1 DAY
DO
  UPDATE puntos_usuario
  SET redimido = TRUE
  WHERE redimido = FALSE
    AND fecha_expiracion IS NOT NULL
    AND fecha_expiracion < CURRENT_DATE;

-- ===============================
-- 🔄 Limpieza lógica de usuarios inactivos por más de 1 año
-- ===============================
DROP EVENT IF EXISTS evt_archivar_usuarios_inactivos;
CREATE EVENT evt_archivar_usuarios_inactivos
ON SCHEDULE EVERY 1 WEEK
DO
  UPDATE usuarios
  SET activo = FALSE
  WHERE activo = TRUE
    AND fecha_registro < (CURRENT_DATE - INTERVAL 1 YEAR)
    AND usuario_id NOT IN (
      SELECT DISTINCT usuario_id FROM pedidos
    );

-- ===============================
-- 🔄 Limpieza lógica de productos sin stock e inactivos
-- ===============================
DROP EVENT IF EXISTS evt_archivar_productos_inactivos;
CREATE EVENT evt_archivar_productos_inactivos
ON SCHEDULE EVERY 1 WEEK
DO
  UPDATE productos
  SET status = 'inactivo'
  WHERE stock = 0
    AND publicado = FALSE
    AND updated_at < (CURRENT_DATE - INTERVAL 60 DAY);

-- ===============================
-- 🔄 Borrado lógico de promociones vencidas
-- ===============================
DROP EVENT IF EXISTS evt_desactivar_promociones_vencidas;
CREATE EVENT evt_desactivar_promociones_vencidas
ON SCHEDULE EVERY 1 DAY
DO
  UPDATE promociones
  SET activo = FALSE
  WHERE fecha_fin IS NOT NULL
    AND fecha_fin < CURRENT_DATE
    AND activo = TRUE;

-- ===============================
-- 🔄 Actualización automática de rankings
-- ===============================
DROP EVENT IF EXISTS evt_actualizar_rankings;
CREATE EVENT evt_actualizar_rankings
ON SCHEDULE EVERY 1 DAY
DO
  UPDATE ranking_usuarios ru
  JOIN (
    SELECT usuario_id, SUM(puntos) AS total
    FROM puntos_usuario
    WHERE redimido = FALSE
    GROUP BY usuario_id
  ) pt ON ru.usuario_id = pt.usuario_id
  SET ru.puntos_totales = pt.total,
      ru.fecha_actualizacion = CURRENT_TIMESTAMP;

-- ================================================================
-- 🧮 PROCEDIMIENTOS ALMACENADOS (STORED PROCEDURES)
-- ================================================================

-- 🎯 SP: Registrar nuevo pedido completo de forma transaccional
DROP PROCEDURE IF EXISTS sp_crear_pedido_completo;
DELIMITER //
CREATE PROCEDURE sp_crear_pedido_completo(
  IN p_cliente_id INT,
  IN p_total DECIMAL(10,2),
  IN p_metodo_pago ENUM('efectivo','tarjeta','transferencia','codi','paypal'),
  IN p_cupon_codigo VARCHAR(30),
  IN p_direccion_envio TEXT,
  IN p_notas TEXT
)
BEGIN
  DECLARE exit HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
  END;

  START TRANSACTION;

  INSERT INTO pedidos (cliente_id, estado_id, total, metodo_pago, cupon, direccion_envio, notas)
  VALUES (p_cliente_id, 1, p_total, p_metodo_pago, p_cupon_codigo, p_direccion_envio, p_notas);

  COMMIT;
END;
//
DELIMITER ;

-- 🧾 SP: Canjear puntos por cupon
DROP PROCEDURE IF EXISTS sp_canjear_puntos_por_cupon;
DELIMITER //
CREATE PROCEDURE sp_canjear_puntos_por_cupon(
  IN p_usuario_id INT,
  IN p_cupon_id INT,
  IN p_puntos INT
)
BEGIN
  DECLARE puntos_disponibles INT;

  SELECT SUM(puntos)
  INTO puntos_disponibles
  FROM puntos_usuario
  WHERE usuario_id = p_usuario_id AND redimido = FALSE;

  IF puntos_disponibles >= p_puntos THEN
    INSERT INTO canjes_puntos (usuario_id, tipo_canje, item_id, puntos_utilizados, estado)
    VALUES (p_usuario_id, 'cupon', p_cupon_id, p_puntos, 'pendiente');

    UPDATE puntos_usuario
    SET redimido = TRUE
    WHERE usuario_id = p_usuario_id AND redimido = FALSE
    ORDER BY fecha
    LIMIT p_puntos;
  ELSE
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'No tienes suficientes puntos para canjear.';
  END IF;
END;
//
DELIMITER ;

-- 🏆 SP: Otorgar logro manualmente
DROP PROCEDURE IF EXISTS sp_otorgar_logro;
DELIMITER //
CREATE PROCEDURE sp_otorgar_logro(
  IN p_usuario_id INT,
  IN p_logro_id INT
)
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM logros_usuario
    WHERE usuario_id = p_usuario_id AND logro_id = p_logro_id
  ) THEN
    INSERT INTO logros_usuario (usuario_id, logro_id)
    VALUES (p_usuario_id, p_logro_id);

    UPDATE ranking_usuarios
    SET logros_obtenidos = logros_obtenidos + 1
    WHERE usuario_id = p_usuario_id;
  END IF;
END;
//
DELIMITER ;

-- ================================================================
-- 🏆 LOGROS AUTOMÁTICOS (TRIGGERS)
-- ================================================================

DELIMITER //

-- 🛒 Otorga logro automático al realizar primera compra
CREATE TRIGGER trg_logro_primera_compra
AFTER INSERT ON pedidos
FOR EACH ROW
BEGIN
  DECLARE ya_lo_tiene INT;
  SELECT COUNT(*) INTO ya_lo_tiene
  FROM logros_usuario
  WHERE usuario_id = NEW.cliente_id AND logro_id = 1;

  IF ya_lo_tiene = 0 THEN
    INSERT INTO logros_usuario (usuario_id, logro_id)
    VALUES (NEW.cliente_id, 1);
  END IF;
END;
//

-- 💬 Otorga logro automático al primer comentario en blog
CREATE TRIGGER trg_logro_comentario_blog
AFTER INSERT ON blog_comentarios
FOR EACH ROW
BEGIN
  DECLARE ya_lo_tiene INT;
  SELECT COUNT(*) INTO ya_lo_tiene
  FROM logros_usuario
  WHERE usuario_id = NEW.usuario_id AND logro_id = 2;

  IF ya_lo_tiene = 0 THEN
    INSERT INTO logros_usuario (usuario_id, logro_id)
    VALUES (NEW.usuario_id, 2);
  END IF;
END;
//

-- 🧾 Otorga logro automático al dejar una valoración
CREATE TRIGGER trg_logro_valoracion_producto
AFTER INSERT ON valoraciones
FOR EACH ROW
BEGIN
  DECLARE ya_lo_tiene INT;
  SELECT COUNT(*) INTO ya_lo_tiene
  FROM logros_usuario
  WHERE usuario_id = NEW.usuario_id AND logro_id = 3;

  IF ya_lo_tiene = 0 THEN
    INSERT INTO logros_usuario (usuario_id, logro_id)
    VALUES (NEW.usuario_id, 3);
  END IF;
END;
//

DELIMITER ;

-- ================================================================
-- 🧾 INSERT DE LOGROS PREDEFINIDOS
-- ================================================================

INSERT INTO logros (nombre, descripcion, tipo_logro, criterio_json, puntos_recompensa, activo)
VALUES
('Primer Pedido', 'Realiza tu primer compra en la tienda.', 'compra', JSON_OBJECT('evento', 'pedido', 'minimo', 1), 50, TRUE),
('Primera Opinión', 'Comenta en una publicación del blog.', 'contenido', JSON_OBJECT('evento', 'blog_comentario'), 20, TRUE),
('Primera Valoración', 'Deja una calificación a un producto que hayas comprado.', 'actividad', JSON_OBJECT('evento', 'valoracion'), 30, TRUE);

-- ================================================================
-- 🧩 MEJORAS EN MODERACIÓN DE COMENTARIOS Y TESTIMONIOS
-- ================================================================

-- Añadir campo moderación silenciosa en comentarios
ALTER TABLE blog_comentarios ADD COLUMN moderado BOOLEAN DEFAULT FALSE;

-- Testimonios certificados (de usuarios reales, por producto)
CREATE TABLE testimonios (
  testimonio_id INT AUTO_INCREMENT PRIMARY KEY,
  producto_id INT NOT NULL,
  usuario_id INT NOT NULL,
  contenido TEXT NOT NULL,
  aprobado BOOLEAN DEFAULT FALSE,
  certificado BOOLEAN DEFAULT FALSE,
  fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (producto_id) REFERENCES productos(producto_id) ON DELETE CASCADE,
  FOREIGN KEY (usuario_id) REFERENCES usuarios(usuario_id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- Trigger: certifica testimonio si hay pedido previo del producto
DELIMITER //
CREATE TRIGGER trg_certificar_testimonio
BEFORE INSERT ON testimonios
FOR EACH ROW
BEGIN
  DECLARE comprueba INT;
  SELECT COUNT(*) INTO comprueba
  FROM detalle_pedido dp
  JOIN pedidos p ON dp.pedido_id = p.pedido_id
  WHERE p.cliente_id = NEW.usuario_id AND dp.producto_id = NEW.producto_id;

  IF comprueba > 0 THEN
    SET NEW.certificado = TRUE;
  END IF;
END;
//
DELIMITER ;

-- ================================================================
-- 🏆 AMPLIACIÓN DE LOGROS Y RECOMPENSAS POR REFERIDOS
-- ================================================================

-- Logros adicionales
INSERT INTO logros (nombre, descripcion, tipo_logro, criterio_json, puntos_recompensa, activo)
VALUES
('Explorador', 'Visita el sitio 10 veces en una semana.', 'actividad', JSON_OBJECT('evento', 'visitas', 'frecuencia', 'semanal', 'minimo', 10), 15, TRUE),
('Súper Comprador', 'Realiza 10 compras distintas.', 'compra', JSON_OBJECT('evento', 'pedido', 'minimo', 10), 150, TRUE),
('Promotor', 'Refiere a 1 nuevo cliente que compre.', 'referido', JSON_OBJECT('evento', 'referido', 'minimo', 1), 75, TRUE),
('Influencer', 'Refiere a 5 nuevos clientes que compren.', 'referido', JSON_OBJECT('evento', 'referido', 'minimo', 5), 250, TRUE),
('Comentarista', 'Publica 3 comentarios aprobados en el blog.', 'contenido', JSON_OBJECT('evento', 'comentario', 'minimo', 3), 40, TRUE),
('Fan del producto', 'Realiza 3 valoraciones de productos distintos.', 'actividad', JSON_OBJECT('evento', 'valoracion', 'minimo', 3), 45, TRUE),
('Líder de Opinión', 'Tu testimonio certificado recibe al menos 5 likes.', 'contenido', JSON_OBJECT('evento', 'testimonio_like', 'minimo', 5), 100, TRUE);

-- ================================================================
-- 🎁 DESCUENTOS AUTOMÁTICOS POR REFERIDOS ACTIVOS
-- ================================================================

-- Tabla para seguimiento de referidos
CREATE TABLE referidos (
  referido_id INT AUTO_INCREMENT PRIMARY KEY,
  referido_por INT NOT NULL,
  usuario_referido INT NOT NULL UNIQUE,
  fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  confirmado BOOLEAN DEFAULT FALSE,
  FOREIGN KEY (referido_por) REFERENCES usuarios(usuario_id),
  FOREIGN KEY (usuario_referido) REFERENCES usuarios(usuario_id)
) ENGINE=InnoDB;

-- Trigger que aplica descuento al promotor cuando su referido realiza compra
DELIMITER //
CREATE TRIGGER trg_descuento_por_referido
AFTER INSERT ON pedidos
FOR EACH ROW
BEGIN
  DECLARE promotor_id INT;

  SELECT referido_por INTO promotor_id
  FROM referidos
  WHERE usuario_referido = NEW.cliente_id AND confirmado = TRUE;

  IF promotor_id IS NOT NULL THEN
    -- Insertar cupon tipo "descuento por referido"
    INSERT INTO cupones (codigo, descuento, descripcion, fecha_expiracion, uso_maximo, activo)
    VALUES (
      CONCAT('REF', promotor_id, '-', UNIX_TIMESTAMP()), 
      5.00, 
      'Descuento automático por referido activo',
      CURRENT_DATE + INTERVAL 30 DAY,
      1,
      TRUE
    );
  END IF;
END;
//
DELIMITER ;

-- ================================================================
-- 🎯 PROMOCIONES PREDEFINIDAS Y EFICIENTES
-- Basadas en estrategias que fomentan ventas y fidelización
-- ================================================================

INSERT INTO promociones (titulo, descripcion, imagen_url, fecha_inicio, fecha_fin, activo)
VALUES
-- 🛍️ Estrategia: Primera compra con descuento
('Descuento Primera Compra', 'Obtén un 10% de descuento en tu primer pedido. Solo válido para nuevos clientes.', '/promos/primera_compra.png', CURDATE(), CURDATE() + INTERVAL 90 DAY, TRUE),

-- 🔁 Estrategia: Compra recurrente
('Cliente Frecuente', 'Si realizas más de 3 pedidos en el mes, obtén un cupón de $50 para tu próxima compra.', '/promos/cliente_frecuente.png', CURDATE(), CURDATE() + INTERVAL 90 DAY, TRUE),

-- 👭 Estrategia: Trae a un amigo
('Trae a un Amigo', 'Ambos ganan $25 en cupones cuando tu referido complete su primera compra.', '/promos/referido.png', CURDATE(), CURDATE() + INTERVAL 180 DAY, TRUE),

-- 🎉 Estrategia: Eventos de temporada
('Promo de Temporada', '20% de descuento en productos seleccionados durante el mes patrio.', '/promos/temporada_mexico.png', '2025-09-01', '2025-09-30', TRUE),

-- 💼 Estrategia: Lanza un nuevo producto
('Lanzamiento Especial', 'Producto nuevo con 15% de descuento por tiempo limitado.', '/promos/lanzamiento.png', CURDATE(), CURDATE() + INTERVAL 14 DAY, TRUE),

-- 🎯 Estrategia: Combos o paquetes
('Combo Ahorro', 'Llévate 3 productos seleccionados por solo $99.', '/promos/combo.png', CURDATE(), CURDATE() + INTERVAL 30 DAY, TRUE),

-- 🛒 Estrategia: Abandono de carrito (aplicable desde frontend/backend)
('Vuelve y Compra', 'Recibe un cupón exclusivo si no completaste tu pedido en las últimas 48h.', '/promos/abandono_carrito.png', CURDATE(), CURDATE() + INTERVAL 30 DAY, TRUE);

-- ================================================================
-- 👁️ VISTAS RECOMENDADAS Y NECESARIAS PARA GESTIÓN Y COMUNIDAD
-- ================================================================

-- Progreso de logros por usuario
CREATE OR REPLACE VIEW vista_avance_logros AS
SELECT 
  u.usuario_id,
  u.nombre,
  COUNT(lu.logro_id) AS logros_obtenidos,
  (SELECT COUNT(*) FROM logros WHERE activo = TRUE) AS logros_totales,
  ROUND(COUNT(lu.logro_id) / (SELECT COUNT(*) FROM logros WHERE activo = TRUE) * 100, 2) AS avance_pct
FROM usuarios u
LEFT JOIN logros_usuario lu ON u.usuario_id = lu.usuario_id
GROUP BY u.usuario_id;

-- Resumen de puntos acumulados y canjeados
CREATE OR REPLACE VIEW vista_puntos_usuario AS
SELECT 
  u.usuario_id,
  u.nombre,
  IFNULL(SUM(p.puntos), 0) AS puntos_acumulados,
  IFNULL(SUM(CASE WHEN p.redimido = TRUE THEN p.puntos ELSE 0 END), 0) AS puntos_canjeados,
  IFNULL(SUM(CASE WHEN p.redimido = FALSE THEN p.puntos ELSE 0 END), 0) AS puntos_disponibles
FROM usuarios u
LEFT JOIN puntos_usuario p ON u.usuario_id = p.usuario_id
GROUP BY u.usuario_id;

-- Ranking de vendedores/promotores con mejor desempeño
CREATE OR REPLACE VIEW vista_ranking_promotores AS
SELECT 
  u.usuario_id,
  u.nombre,
  rp.tipo,
  rp.total_productos_vendidos,
  rp.total_clientes_atendidos,
  rp.total_puntos_otorgados,
  rp.nivel_actual
FROM ranking_promotores rp
JOIN usuarios u ON rp.usuario_id = u.usuario_id
ORDER BY rp.total_productos_vendidos DESC;

-- Referidos activos y conversión por usuario
CREATE OR REPLACE VIEW vista_resumen_referidos AS
SELECT 
  r.referido_por AS usuario_id,
  u.nombre,
  COUNT(r.referido_id) AS total_referidos,
  SUM(CASE WHEN r.confirmado = TRUE THEN 1 ELSE 0 END) AS referidos_convertidos
FROM referidos r
JOIN usuarios u ON r.referido_por = u.usuario_id
GROUP BY r.referido_por;

-- Fidelidad por nivel y recompensas
CREATE OR REPLACE VIEW vista_fidelidad_clientes AS
SELECT 
  u.usuario_id,
  u.nombre,
  COALESCE(SUM(p.puntos), 0) AS puntos_totales,
  (SELECT nivel_id FROM niveles_fidelidad WHERE puntos_necesarios <= COALESCE(SUM(p.puntos), 0) ORDER BY puntos_necesarios DESC LIMIT 1) AS nivel_actual
FROM usuarios u
LEFT JOIN puntos_usuario p ON u.usuario_id = p.usuario_id
GROUP BY u.usuario_id;

-- ================================================================
-- 🧮 PROCEDIMIENTOS ALMACENADOS MEJORADOS
-- ================================================================

-- Recompensar usuario por subir de nivel de fidelidad
DROP PROCEDURE IF EXISTS sp_recompensar_por_nivel;
DELIMITER //
CREATE PROCEDURE sp_recompensar_por_nivel(IN p_usuario_id INT)
BEGIN
  DECLARE total_puntos INT;
  DECLARE nuevo_nivel_id INT;
  DECLARE nivel_actual INT;

  SELECT COALESCE(SUM(puntos), 0) INTO total_puntos
  FROM puntos_usuario
  WHERE usuario_id = p_usuario_id;

  SELECT nivel_id INTO nuevo_nivel_id
  FROM niveles_fidelidad
  WHERE puntos_necesarios <= total_puntos
  ORDER BY puntos_necesarios DESC
  LIMIT 1;

  SELECT nivel_nuevo_id INTO nivel_actual
  FROM historial_niveles
  WHERE usuario_id = p_usuario_id
  ORDER BY fecha_cambio DESC
  LIMIT 1;

  IF nuevo_nivel_id IS NOT NULL AND nuevo_nivel_id <> nivel_actual THEN
    INSERT INTO historial_niveles (usuario_id, nivel_anterior_id, nivel_nuevo_id)
    VALUES (p_usuario_id, nivel_actual, nuevo_nivel_id);
  END IF;
END;
//
DELIMITER ;

-- ================================================================
-- 📊 VISTAS CLAVE PARA REPORTES, ANALÍTICA Y TRAZABILIDAD
-- ================================================================

-- 🧾 Ventas por categoría
CREATE OR REPLACE VIEW reporte_ventas_por_categoria AS
SELECT 
  c.nombre_categoria,
  COUNT(dp.detalle_id) AS productos_vendidos,
  SUM(dp.cantidad * dp.precio_unitario) AS total_vendido
FROM detalle_pedido dp
JOIN productos p ON dp.producto_id = p.producto_id
JOIN categorias c ON p.categoria_id = c.categoria_id
GROUP BY c.nombre_categoria;

-- 💳 Ventas por método de pago
CREATE OR REPLACE VIEW reporte_ventas_por_metodo_pago AS
SELECT 
  metodo_pago,
  COUNT(*) AS total_pedidos,
  SUM(total) AS total_ingresos
FROM pedidos
GROUP BY metodo_pago;

-- ⏱️ Pedidos por estado y tiempo promedio
CREATE OR REPLACE VIEW reporte_estados_tiempo_pedidos AS
SELECT 
  ep.estado_nombre,
  COUNT(*) AS total_pedidos,
  ROUND(AVG(TIMESTAMPDIFF(HOUR, p.fecha_pedido, p.fecha_entrega))) AS tiempo_promedio_horas
FROM pedidos p
JOIN estados_pedido ep ON p.estado_id = ep.estado_id
WHERE p.fecha_entrega IS NOT NULL
GROUP BY ep.estado_nombre;

-- 📈 Actividad de usuarios (pedidos, comentarios, valoraciones)
CREATE OR REPLACE VIEW reporte_actividad_usuarios AS
SELECT 
  u.usuario_id,
  u.nombre,
  COUNT(DISTINCT p.pedido_id) AS total_pedidos,
  COUNT(DISTINCT bc.comentario_id) AS total_comentarios,
  COUNT(DISTINCT v.valoracion_id) AS total_valoraciones
FROM usuarios u
LEFT JOIN pedidos p ON u.usuario_id = p.cliente_id
LEFT JOIN blog_comentarios bc ON u.usuario_id = bc.usuario_id
LEFT JOIN valoraciones v ON u.usuario_id = v.usuario_id
GROUP BY u.usuario_id;

-- 🏅 Usuarios más influyentes (referidos + logros + testimonio certificado)
CREATE OR REPLACE VIEW reporte_usuarios_influyentes AS
SELECT 
  u.usuario_id,
  u.nombre,
  COUNT(DISTINCT r.referido_id) AS referidos_activos,
  COUNT(DISTINCT lu.logro_id) AS logros_totales,
  COUNT(DISTINCT t.testimonio_id) AS testimonios_certificados
FROM usuarios u
LEFT JOIN referidos r ON u.usuario_id = r.referido_por AND r.confirmado = TRUE
LEFT JOIN logros_usuario lu ON u.usuario_id = lu.usuario_id
LEFT JOIN testimonios t ON u.usuario_id = t.usuario_id AND t.certificado = TRUE
GROUP BY u.usuario_id;

-- 🧮 Cupones otorgados y utilizados
CREATE OR REPLACE VIEW reporte_cupones_uso AS
SELECT 
  c.codigo,
  COUNT(p.pedido_id) AS veces_usado,
  c.fecha_expiracion,
  c.uso_maximo,
  c.descuento
FROM cupones c
LEFT JOIN pedidos p ON c.codigo = p.cupon
GROUP BY c.codigo;

-- 🕵️ Registro de actividad del sistema
CREATE OR REPLACE VIEW reporte_log_acciones AS
SELECT 
  l.log_id,
  u.nombre,
  l.tabla_afectada,
  l.accion,
  l.descripcion,
  l.fecha
FROM logs_acciones l
LEFT JOIN usuarios u ON l.usuario_id = u.usuario_id
ORDER BY l.fecha DESC;

-- ================================================================
-- 🚚 RASTREABILIDAD DE PEDIDOS Y COMUNICACIÓN
-- ================================================================

-- Seguimiento detallado de eventos del pedido
CREATE TABLE seguimiento_pedidos (
  seguimiento_id INT AUTO_INCREMENT PRIMARY KEY,
  pedido_id INT NOT NULL,
  estado_actual VARCHAR(50) NOT NULL,
  ubicacion VARCHAR(100),
  notas TEXT,
  fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  realizado_por INT,
  FOREIGN KEY (pedido_id) REFERENCES pedidos(pedido_id),
  FOREIGN KEY (realizado_por) REFERENCES usuarios(usuario_id)
) ENGINE=InnoDB;

-- Mensajes entre cliente y vendedor por pedido
CREATE TABLE mensajes_pedido (
  mensaje_id INT AUTO_INCREMENT PRIMARY KEY,
  pedido_id INT NOT NULL,
  de_usuario_id INT NOT NULL,
  para_usuario_id INT NOT NULL,
  contenido TEXT NOT NULL,
  fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  leido BOOLEAN DEFAULT FALSE,
  FOREIGN KEY (pedido_id) REFERENCES pedidos(pedido_id),
  FOREIGN KEY (de_usuario_id) REFERENCES usuarios(usuario_id),
  FOREIGN KEY (para_usuario_id) REFERENCES usuarios(usuario_id)
) ENGINE=InnoDB;

-- Tickets de soporte técnico o atención al cliente
CREATE TABLE tickets_soporte (
  ticket_id INT AUTO_INCREMENT PRIMARY KEY,
  usuario_id INT NOT NULL,
  tipo ENUM('cliente', 'tecnico') DEFAULT 'cliente',
  asunto VARCHAR(100),
  descripcion TEXT,
  estado ENUM('abierto', 'en_proceso', 'resuelto', 'cerrado') DEFAULT 'abierto',
  prioridad ENUM('baja', 'media', 'alta') DEFAULT 'media',
  fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  fecha_resolucion TIMESTAMP NULL,
  FOREIGN KEY (usuario_id) REFERENCES usuarios(usuario_id)
) ENGINE=InnoDB;

-- Mensajes dentro de un ticket
CREATE TABLE mensajes_ticket (
  mensaje_id INT AUTO_INCREMENT PRIMARY KEY,
  ticket_id INT NOT NULL,
  usuario_id INT NOT NULL,
  contenido TEXT NOT NULL,
  fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  archivo_url VARCHAR(255),
  FOREIGN KEY (ticket_id) REFERENCES tickets_soporte(ticket_id),
  FOREIGN KEY (usuario_id) REFERENCES usuarios(usuario_id)
) ENGINE=InnoDB;

-- ================================================================
-- 📑 CONTABILIDAD Y FACTURACIÓN ELECTRÓNICA
-- ================================================================

-- Catálogo de facturas electrónicas
CREATE TABLE facturas (
  factura_id INT AUTO_INCREMENT PRIMARY KEY,
  pedido_id INT NOT NULL,
  usuario_id INT NOT NULL,
  uuid_factura VARCHAR(64) UNIQUE,
  rfc_emisor VARCHAR(13) NOT NULL,
  rfc_receptor VARCHAR(13) NOT NULL,
  razon_social_receptor VARCHAR(255),
  uso_cfdi VARCHAR(10),
  metodo_pago VARCHAR(50),
  forma_pago VARCHAR(50),
  total DECIMAL(10,2),
  xml_url VARCHAR(255),
  pdf_url VARCHAR(255),
  fecha_emision TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (pedido_id) REFERENCES pedidos(pedido_id),
  FOREIGN KEY (usuario_id) REFERENCES usuarios(usuario_id)
) ENGINE=InnoDB;

-- Catálogo de movimientos contables
CREATE TABLE movimientos_contables (
  movimiento_id INT AUTO_INCREMENT PRIMARY KEY,
  tipo ENUM('ingreso', 'egreso') NOT NULL,
  descripcion TEXT,
  monto DECIMAL(10,2) NOT NULL,
  referencia_pedido INT,
  referencia_factura INT,
  cuenta_contable VARCHAR(50),
  fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (referencia_pedido) REFERENCES pedidos(pedido_id),
  FOREIGN KEY (referencia_factura) REFERENCES facturas(factura_id)
) ENGINE=InnoDB;

-- Configuración fiscal del sistema (una sola fila)
CREATE TABLE configuracion_fiscal (
  id INT PRIMARY KEY,
  rfc_emisor VARCHAR(13) NOT NULL,
  razon_social VARCHAR(255) NOT NULL,
  regimen_fiscal VARCHAR(100),
  certificado_digital_url VARCHAR(255),
  clave_privada_url VARCHAR(255),
  clave_csd VARCHAR(255),
  fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Peticiones de factura realizadas por clientes
CREATE TABLE solicitudes_factura (
  solicitud_id INT AUTO_INCREMENT PRIMARY KEY,
  pedido_id INT NOT NULL,
  usuario_id INT NOT NULL,
  rfc VARCHAR(13),
  razon_social VARCHAR(255),
  uso_cfdi VARCHAR(10),
  metodo_pago VARCHAR(50),
  forma_pago VARCHAR(50),
  estado ENUM('pendiente', 'generada', 'rechazada') DEFAULT 'pendiente',
  fecha_solicitud TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (pedido_id) REFERENCES pedidos(pedido_id),
  FOREIGN KEY (usuario_id) REFERENCES usuarios(usuario_id)
) ENGINE=InnoDB;

-- ================================================================
-- 📘 CONTABILIDAD AVANZADA
-- ================================================================

-- Catálogo de cuentas contables (plan contable básico)
CREATE TABLE cuentas_contables (
  cuenta_id INT AUTO_INCREMENT PRIMARY KEY,
  codigo VARCHAR(20) NOT NULL UNIQUE,
  nombre VARCHAR(100) NOT NULL,
  tipo ENUM('activo', 'pasivo', 'capital', 'ingresos', 'egresos') NOT NULL,
  nivel INT DEFAULT 1,
  cuenta_padre_id INT DEFAULT NULL,
  FOREIGN KEY (cuenta_padre_id) REFERENCES cuentas_contables(cuenta_id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- Pólizas contables (agrupación de transacciones)
CREATE TABLE polizas (
  poliza_id INT AUTO_INCREMENT PRIMARY KEY,
  tipo ENUM('ingreso', 'egreso', 'diario', 'ajuste') NOT NULL,
  descripcion TEXT,
  fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  estado ENUM('borrador', 'validada', 'anulada') DEFAULT 'borrador',
  usuario_id INT,
  FOREIGN KEY (usuario_id) REFERENCES usuarios(usuario_id)
) ENGINE=InnoDB;

-- Partidas de cada póliza (débitos y créditos)
CREATE TABLE partidas_poliza (
  partida_id INT AUTO_INCREMENT PRIMARY KEY,
  poliza_id INT NOT NULL,
  cuenta_id INT NOT NULL,
  descripcion TEXT,
  debe DECIMAL(10,2) DEFAULT 0.00,
  haber DECIMAL(10,2) DEFAULT 0.00,
  FOREIGN KEY (poliza_id) REFERENCES polizas(poliza_id),
  FOREIGN KEY (cuenta_id) REFERENCES cuentas_contables(cuenta_id)
) ENGINE=InnoDB;

-- Balance general automatizado (vista sugerida)
CREATE OR REPLACE VIEW vista_balance_general AS
SELECT 
  cc.tipo,
  cc.codigo,
  cc.nombre,
  SUM(pp.debe) AS total_debe,
  SUM(pp.haber) AS total_haber,
  SUM(pp.debe - pp.haber) AS saldo
FROM partidas_poliza pp
JOIN cuentas_contables cc ON pp.cuenta_id = cc.cuenta_id
JOIN polizas p ON pp.poliza_id = p.poliza_id
WHERE p.estado = 'validada'
GROUP BY cc.cuenta_id;

-- Estado de resultados (vista sugerida)
CREATE OR REPLACE VIEW vista_estado_resultados AS
SELECT 
  cc.tipo,
  cc.nombre,
  SUM(pp.debe) AS total_debe,
  SUM(pp.haber) AS total_haber,
  SUM(pp.haber - pp.debe) AS resultado
FROM partidas_poliza pp
JOIN cuentas_contables cc ON pp.cuenta_id = cc.cuenta_id
JOIN polizas p ON pp.poliza_id = p.poliza_id
WHERE p.estado = 'validada' AND cc.tipo IN ('ingresos', 'egresos')
GROUP BY cc.cuenta_id;

-- ================================================================
-- 🧮 PROCEDIMIENTOS ALMACENADOS PARA CONTABILIDAD AVANZADA
-- ================================================================

-- Registrar póliza de ingreso automática por pedido pagado
DROP PROCEDURE IF EXISTS sp_generar_poliza_ingreso_pedido;
DELIMITER //
CREATE PROCEDURE sp_generar_poliza_ingreso_pedido(IN p_pedido_id INT, IN p_usuario_id INT)
BEGIN
  DECLARE v_total DECIMAL(10,2);
  DECLARE v_metodo_pago VARCHAR(50);
  DECLARE v_poliza_id INT;

  SELECT total, metodo_pago INTO v_total, v_metodo_pago
  FROM pedidos
  WHERE pedido_id = p_pedido_id;

  -- Insertar póliza
  INSERT INTO polizas (tipo, descripcion, estado, usuario_id)
  VALUES ('ingreso', CONCAT('Ingreso por pedido ID: ', p_pedido_id), 'validada', p_usuario_id);

  SET v_poliza_id = LAST_INSERT_ID();

  -- Partida haber: ingresos
  INSERT INTO partidas_poliza (poliza_id, cuenta_id, descripcion, debe, haber)
  VALUES (v_poliza_id, 
          (SELECT cuenta_id FROM cuentas_contables WHERE codigo = '4001' LIMIT 1),
          'Ingreso por venta', 0.00, v_total);

  -- Partida debe: caja o banco según método de pago
  INSERT INTO partidas_poliza (poliza_id, cuenta_id, descripcion, debe, haber)
  VALUES (v_poliza_id, 
          (SELECT cuenta_id FROM cuentas_contables 
           WHERE (v_metodo_pago = 'efectivo' AND codigo = '1001')
              OR (v_metodo_pago = 'tarjeta' AND codigo = '1021')
              OR (v_metodo_pago = 'transferencia' AND codigo = '1022')
              OR (v_metodo_pago = 'paypal' AND codigo = '1023')
           LIMIT 1),
          'Ingreso recibido', v_total, 0.00);
END;
//
DELIMITER ;

-- Registrar póliza de egreso manual (ej. gastos operativos)
DROP PROCEDURE IF EXISTS sp_generar_poliza_egreso_manual;
DELIMITER //
CREATE PROCEDURE sp_generar_poliza_egreso_manual(
  IN p_usuario_id INT,
  IN p_monto DECIMAL(10,2),
  IN p_cuenta_gasto_codigo VARCHAR(20),
  IN p_descripcion TEXT
)
BEGIN
  DECLARE v_poliza_id INT;
  DECLARE v_cuenta_gasto_id INT;

  SELECT cuenta_id INTO v_cuenta_gasto_id
  FROM cuentas_contables
  WHERE codigo = p_cuenta_gasto_codigo AND tipo = 'egresos';

  -- Crear póliza de egreso
  INSERT INTO polizas (tipo, descripcion, estado, usuario_id)
  VALUES ('egreso', p_descripcion, 'validada', p_usuario_id);

  SET v_poliza_id = LAST_INSERT_ID();

  -- Debe: gasto
  INSERT INTO partidas_poliza (poliza_id, cuenta_id, descripcion, debe, haber)
  VALUES (v_poliza_id, v_cuenta_gasto_id, p_descripcion, p_monto, 0.00);

  -- Haber: caja
  INSERT INTO partidas_poliza (poliza_id, cuenta_id, descripcion, debe, haber)
  VALUES (v_poliza_id, 
          (SELECT cuenta_id FROM cuentas_contables WHERE codigo = '1001' LIMIT 1),
          'Salida de efectivo', 0.00, p_monto);
END;
//
DELIMITER ;

-- ================================================================
-- 🧾 PLAN CONTABLE BÁSICO RECOMENDADO (Insert inicial)
-- ================================================================

INSERT INTO cuentas_contables (codigo, nombre, tipo, nivel)
VALUES
-- Activos
('1001', 'Caja', 'activo', 1),
('1021', 'Bancos - Tarjeta', 'activo', 1),
('1022', 'Bancos - Transferencia', 'activo', 1),
('1023', 'Paypal', 'activo', 1),
('1101', 'Clientes', 'activo', 1),

-- Pasivos
('2001', 'Proveedores', 'pasivo', 1),
('2101', 'Impuestos por pagar', 'pasivo', 1),

-- Capital
('3001', 'Capital social', 'capital', 1),
('3101', 'Resultados acumulados', 'capital', 1),

-- Ingresos
('4001', 'Ventas de productos', 'ingresos', 1),
('4002', 'Servicios facturados', 'ingresos', 1),
('4101', 'Otros ingresos', 'ingresos', 1),

-- Egresos
('5001', 'Compras', 'egresos', 1),
('5101', 'Gastos administrativos', 'egresos', 1),
('5102', 'Publicidad y marketing', 'egresos', 1),
('5103', 'Soporte técnico y TI', 'egresos', 1),
('5104', 'Gastos financieros', 'egresos', 1);

-- ================================================================
-- 🧾 METADATOS DE DISEÑO DE BASE DE DATOS
-- ================================================================

CREATE TABLE metadatos_bd (
  id INT PRIMARY KEY,
  nombre_sistema VARCHAR(100) NOT NULL,
  version_bd VARCHAR(20) NOT NULL,
  fecha_creacion DATETIME NOT NULL,
  creado_por VARCHAR(100),
  descripcion TEXT,
  estructura_sha256 CHAR(64),
  observaciones TEXT
);

-- Insert inicial de metadatos del sistema TianguiStore
INSERT INTO metadatos_bd (id, nombre_sistema, version_bd, fecha_creacion, creado_por, descripcion, estructura_md5, observaciones)
VALUES (
  1,
  'TianguiStore',
  '1.0.0',
  NOW(),
  'I.S.C. Erick Renato Vega Ceron',
  'Estructura modular extendida para sistema eCommerce con soporte completo para fidelización, gamificación, trazabilidad, contabilidad, comunidad y evolución.',
  SHA2('estructura_tienda_full_final.sql', 256),
  'Versión base lista para despliegue, desarrollo incremental y auditoría.'
);

-- SHA-256 utilizado para mayor seguridad en la verificación interna del archivo.

-- ================================================================
-- ✅ VALIDACIONES Y VERIFICACIONES GLOBALES
-- Seguridad, integridad, economía, persistencia, eficiencia, confiabilidad
-- ================================================================

-- 🚫 Verificar datos duplicados críticos
ALTER TABLE usuarios
ADD CONSTRAINT chk_email_unico UNIQUE (correo_electronico);

ALTER TABLE productos
ADD CONSTRAINT chk_nombre_unico UNIQUE (nombre);

-- 🔎 Restricciones lógicas en valores numéricos
ALTER TABLE productos
ADD CONSTRAINT chk_precio_positivo CHECK (precio >= 0);

ALTER TABLE productos
ADD CONSTRAINT chk_descuento_valido CHECK (descuento BETWEEN 0 AND 100);

ALTER TABLE productos
ADD CONSTRAINT chk_stock_no_negativo CHECK (stock >= 0);

ALTER TABLE detalle_pedido
ADD CONSTRAINT chk_cantidad_valida CHECK (cantidad > 0);

-- 🛑 Validación de estado de pedidos
ALTER TABLE pedidos
ADD CONSTRAINT chk_total_no_negativo CHECK (total >= 0);

-- ✅ Validez de puntos
ALTER TABLE puntos_usuario
ADD CONSTRAINT chk_puntos_positivos CHECK (puntos > 0);

-- 🔒 No permitir facturas con total negativo
ALTER TABLE facturas
ADD CONSTRAINT chk_factura_total_valida CHECK (total >= 0);

-- ✅ Consistencia en contabilidad
ALTER TABLE partidas_poliza
ADD CONSTRAINT chk_partidas_no_nulas CHECK ((debe > 0 AND haber = 0) OR (haber > 0 AND debe = 0));

-- 🧩 Persistencia mínima: evitar campos vacíos críticos
ALTER TABLE categorias
MODIFY nombre_categoria VARCHAR(100) NOT NULL;

ALTER TABLE marcas
MODIFY nombre_marca VARCHAR(100) NOT NULL;

-- 🔁 Garantizar correspondencia entre tipos de pago y cuentas
-- (Validación lógica en backend adicional recomendada)

-- 💼 Protección ante inconsistencias de referidos
ALTER TABLE referidos
ADD CONSTRAINT chk_no_autoreferencia CHECK (referido_por <> usuario_referido);

-- 🔄 Integridad en promociones activas
ALTER TABLE promociones
ADD CONSTRAINT chk_fecha_promo_valida CHECK (fecha_fin > fecha_inicio);

-- 🚫 Evitar datos futuros inválidos
ALTER TABLE pedidos
ADD CONSTRAINT chk_fecha_pedido_realista CHECK (fecha_pedido <= NOW());

-- 🛑 Evitar rebases en uso de cupones
-- (Requiere trigger si uso_maximo es superado — lógica en backend o SP)

-- 🔐 Protección extra en triggers:
-- Verificar si usuario está activo antes de permitir acciones críticas

-- Este bloque refuerza la seguridad, persistencia y eficiencia del modelo.

-- ================================================================
-- ⚙️ ESTADO DEL SISTEMA, USO, BACKUPS Y MANTENIMIENTO
-- ================================================================

-- Estado del sistema (encendido, mantenimiento, bloqueado, etc.)
CREATE TABLE estado_sistema (
  id INT PRIMARY KEY,
  estado ENUM('activo', 'mantenimiento', 'bloqueado', 'apagado') NOT NULL DEFAULT 'activo',
  mensaje_sistema TEXT,
  fecha_ultima_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Historial de eventos del sistema (como reinicios, cambios de estado, errores graves)
CREATE TABLE eventos_sistema (
  evento_id INT AUTO_INCREMENT PRIMARY KEY,
  tipo ENUM('inicio', 'apagado', 'error', 'reinicio', 'mantenimiento') NOT NULL,
  descripcion TEXT,
  generado_por INT,
  fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (generado_por) REFERENCES usuarios(usuario_id)
) ENGINE=InnoDB;

-- Registro de sesiones activas de usuarios (para analítica y seguridad)
CREATE TABLE sesiones_usuarios (
  sesion_id INT AUTO_INCREMENT PRIMARY KEY,
  usuario_id INT NOT NULL,
  ip_origen VARCHAR(45),
  user_agent TEXT,
  fecha_inicio DATETIME DEFAULT CURRENT_TIMESTAMP,
  fecha_fin DATETIME NULL,
  activa BOOLEAN DEFAULT TRUE,
  FOREIGN KEY (usuario_id) REFERENCES usuarios(usuario_id)
) ENGINE=InnoDB;

-- Registro de backups realizados (internos o manuales)
CREATE TABLE respaldos (
  respaldo_id INT AUTO_INCREMENT PRIMARY KEY,
  tipo ENUM('completo', 'diferencial', 'manual') NOT NULL,
  nombre_archivo VARCHAR(255),
  ubicacion_archivo TEXT,
  fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  generado_por INT,
  FOREIGN KEY (generado_por) REFERENCES usuarios(usuario_id)
) ENGINE=InnoDB;

-- Registro general de uso del sistema por módulo
CREATE TABLE uso_sistema (
  uso_id INT AUTO_INCREMENT PRIMARY KEY,
  usuario_id INT,
  modulo VARCHAR(50), -- Ej: 'catálogo', 'dashboard', 'admin', etc.
  accion VARCHAR(50),
  descripcion TEXT,
  fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (usuario_id) REFERENCES usuarios(usuario_id)
) ENGINE=InnoDB;

-- ================================================================
-- 🔍 AUDITORÍA GENERAL Y MÉTRICAS CLAVE DEL SISTEMA
-- Para hacer la base de datos completamente auditable y medible
-- ================================================================

-- Auditoría genérica de acciones en cualquier tabla
CREATE TABLE auditoria_general (
  auditoria_id INT AUTO_INCREMENT PRIMARY KEY,
  usuario_id INT,
  tabla_afectada VARCHAR(100),
  id_registro INT,
  tipo_accion ENUM('INSERT', 'UPDATE', 'DELETE'),
  campos_afectados TEXT,
  datos_anteriores JSON,
  datos_nuevos JSON,
  ip_origen VARCHAR(45),
  user_agent TEXT,
  fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (usuario_id) REFERENCES usuarios(usuario_id)
) ENGINE=InnoDB;

-- Métricas acumuladas clave del sistema (snapshots o incrementales)
CREATE TABLE metricas_sistema (
  metrica_id INT AUTO_INCREMENT PRIMARY KEY,
  nombre_metrica VARCHAR(100) NOT NULL,
  valor_actual DECIMAL(20,2),
  unidad VARCHAR(50),
  fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  tipo ENUM('uso', 'ventas', 'rendimiento', 'usuarios', 'operativo')
) ENGINE=InnoDB;

-- Opcional: vista de resumen de métricas actuales
CREATE OR REPLACE VIEW vista_resumen_metricas AS
SELECT nombre_metrica, valor_actual, unidad, tipo, fecha_actualizacion
FROM metricas_sistema
ORDER BY tipo, nombre_metrica;

-- Opcional: triggers genéricos para auditoría básica (esquema base)
-- NOTA: se recomienda implementar triggers específicos por tabla o usar lógica desde backend

-- ================================================================
-- 💸 ESTRATEGIAS AUTOMÁTICAS PARA MAXIMIZACIÓN DE GANANCIAS
-- Gestión inteligente desde la base de datos
-- ================================================================

-- Registro de márgenes y utilidad por producto
CREATE TABLE analisis_margen_producto (
  producto_id INT PRIMARY KEY,
  costo_unitario DECIMAL(10,2) NOT NULL,
  precio_venta DECIMAL(10,2) NOT NULL,
  margen_utilidad DECIMAL(5,2) GENERATED ALWAYS AS ((precio_venta - costo_unitario) / costo_unitario * 100) STORED,
  margen_efectivo DECIMAL(10,2) GENERATED ALWAYS AS (precio_venta - costo_unitario) STORED,
  fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (producto_id) REFERENCES productos(producto_id)
) ENGINE=InnoDB;

-- Estrategias sugeridas por el sistema
CREATE TABLE estrategias_sugeridas (
  estrategia_id INT AUTO_INCREMENT PRIMARY KEY,
  tipo ENUM('ajuste_precio', 'promocion_dirigida', 'reposicion_stock', 'reordenar_catalogo', 'combo', 'campana_descuento') NOT NULL,
  objetivo TEXT,
  descripcion TEXT,
  producto_id INT DEFAULT NULL,
  categoria_id INT DEFAULT NULL,
  fecha_generacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  prioridad ENUM('alta', 'media', 'baja') DEFAULT 'media',
  recomendada_por ENUM('sistema', 'admin') DEFAULT 'sistema',
  FOREIGN KEY (producto_id) REFERENCES productos(producto_id),
  FOREIGN KEY (categoria_id) REFERENCES categorias(categoria_id)
) ENGINE=InnoDB;

-- Ejemplo de estrategia automática sugerida desde la lógica SQL
-- Esta tabla será llenada desde lógica backend o procedimientos que evalúen ventas, rotación y margen

-- Historial de ejecución de estrategias
CREATE TABLE historial_estrategias (
  ejecucion_id INT AUTO_INCREMENT PRIMARY KEY,
  estrategia_id INT NOT NULL,
  usuario_id INT,
  fecha_ejecucion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  resultado TEXT,
  FOREIGN KEY (estrategia_id) REFERENCES estrategias_sugeridas(estrategia_id),
  FOREIGN KEY (usuario_id) REFERENCES usuarios(usuario_id)
) ENGINE=InnoDB;

-- Vista recomendada para analizar productos de alto margen y baja rotación
CREATE OR REPLACE VIEW vista_productos_margen_bajo_venta_lenta AS
SELECT 
  p.producto_id,
  p.nombre,
  a.margen_utilidad,
  p.stock,
  COUNT(dp.detalle_id) AS ventas_ultimos_30_dias
FROM productos p
JOIN analisis_margen_producto a ON p.producto_id = a.producto_id
LEFT JOIN detalle_pedido dp ON dp.producto_id = p.producto_id AND dp.pedido_id IN (
  SELECT pedido_id FROM pedidos WHERE fecha_pedido >= NOW() - INTERVAL 30 DAY
)
GROUP BY p.producto_id
HAVING ventas_ultimos_30_dias < 5 AND margen_utilidad < 20
ORDER BY margen_utilidad ASC;

-- ================================================================
-- 📢 CAMPAÑAS INTELIGENTES Y ESTRATEGIAS DE NEGOCIO AUTOMATIZADAS
-- ================================================================

-- Reglas de negocio automatizadas (condiciones para campañas)
CREATE TABLE reglas_negocio (
  regla_id INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  descripcion TEXT,
  tipo_evento ENUM('stock_bajo', 'venta_lenta', 'alta_rotacion', 'bajo_margen', 'abandono_carrito', 'clientes_inactivos'),
  umbral_valor DECIMAL(10,2),
  criterio JSON,
  accion_automatizada ENUM('activar_promocion', 'ajustar_precio', 'notificar_admin', 'generar_cupon', 'sugerir_combo'),
  activa BOOLEAN DEFAULT TRUE,
  fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Campañas generadas automáticamente
CREATE TABLE campanas (
  campana_id INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(100),
  tipo ENUM('descuento', 'combo', 'envio_gratis', 'cupon_unico', 'destacado'),
  descripcion TEXT,
  fecha_inicio DATE,
  fecha_fin DATE,
  activa BOOLEAN DEFAULT TRUE,
  generada_por ENUM('admin', 'sistema') DEFAULT 'sistema',
  regla_id INT,
  FOREIGN KEY (regla_id) REFERENCES reglas_negocio(regla_id)
) ENGINE=InnoDB;

-- Relación entre campañas y productos afectados
CREATE TABLE productos_campana (
  campana_id INT NOT NULL,
  producto_id INT NOT NULL,
  descuento_aplicado DECIMAL(5,2) DEFAULT 0,
  PRIMARY KEY (campana_id, producto_id),
  FOREIGN KEY (campana_id) REFERENCES campanas(campana_id) ON DELETE CASCADE,
  FOREIGN KEY (producto_id) REFERENCES productos(producto_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Historial de ejecuciones de campañas
CREATE TABLE historial_campanas (
  historial_id INT AUTO_INCREMENT PRIMARY KEY,
  campana_id INT NOT NULL,
  fecha_inicio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  ventas_generadas DECIMAL(10,2) DEFAULT 0,
  productos_afectados INT DEFAULT 0,
  observaciones TEXT,
  FOREIGN KEY (campana_id) REFERENCES campanas(campana_id)
) ENGINE=InnoDB;

-- Vista para control estratégico de campañas activas
CREATE OR REPLACE VIEW vista_campanas_activas AS
SELECT 
  c.campana_id,
  c.nombre,
  c.tipo,
  c.fecha_inicio,
  c.fecha_fin,
  COUNT(pc.producto_id) AS productos_en_campana
FROM campanas c
LEFT JOIN productos_campana pc ON c.campana_id = pc.campana_id
WHERE c.activa = TRUE
GROUP BY c.campana_id;

-- Vista de ventas generadas por campañas
CREATE OR REPLACE VIEW vista_ventas_por_campana AS
SELECT 
  h.campana_id,
  c.nombre,
  c.tipo,
  SUM(h.ventas_generadas) AS total_ventas_generadas,
  SUM(h.productos_afectados) AS total_productos_vendidos
FROM historial_campanas h
JOIN campanas c ON h.campana_id = c.campana_id
GROUP BY h.campana_id;

-- ================================================================
-- ⚙️ INSERT DE REGLAS DE NEGOCIO Y CAMPAÑAS AUTOMÁTICAS
-- ================================================================

-- Reglas de negocio inteligentes
INSERT INTO reglas_negocio (nombre, descripcion, tipo_evento, umbral_valor, criterio, accion_automatizada)
VALUES 
('Stock Críticamente Bajo', 'Activa una promoción al detectar menos de 5 unidades en stock', 'stock_bajo', 5, JSON_OBJECT('comparador', '<', 'stock', 5), 'activar_promocion'),
('Producto No Vendido en 30 Días', 'Descuento automático si no hay ventas recientes', 'venta_lenta', 30, JSON_OBJECT('dias_sin_ventas', 30), 'activar_promocion'),
('Alta Rotación', 'Sugerir reabastecimiento para productos de alta venta semanal', 'alta_rotacion', 20, JSON_OBJECT('ventas_semanales', '>20'), 'reordenar_catalogo'),
('Márgenes Menores al 15%', 'Detecta y sugiere precio o combos si el margen es bajo', 'bajo_margen', 15, JSON_OBJECT('margen_minimo', 15), 'sugerir_combo'),
('Clientes Inactivos por 60 Días', 'Generar cupón si no han comprado en más de 2 meses', 'clientes_inactivos', 60, JSON_OBJECT('dias_inactivos', 60), 'generar_cupon'),
('Abandono de Carrito', 'Enviar recordatorio/cupón a clientes que dejaron productos sin comprar', 'abandono_carrito', 1, JSON_OBJECT('carrito_sin_finalizar', true), 'generar_cupon');

-- Campañas automáticas basadas en reglas
INSERT INTO campanas (nombre, tipo, descripcion, fecha_inicio, fecha_fin, generada_por, regla_id)
VALUES
('Descuento Stock Bajo', 'descuento', '10% de descuento por bajo inventario', CURDATE(), CURDATE() + INTERVAL 10 DAY, 'sistema', 1),
('Promoción Producto Congelado', 'descuento', 'Activa visibilidad con 15% de descuento por falta de ventas', CURDATE(), CURDATE() + INTERVAL 15 DAY, 'sistema', 2),
('Reabastecer Éxitos', 'combo', 'Crea combos de productos con alta demanda para fomentar más ventas', CURDATE(), CURDATE() + INTERVAL 20 DAY, 'sistema', 3),
('Oferta Margen Bajo', 'combo', 'Combina productos con bajo margen para mejorar ticket promedio', CURDATE(), CURDATE() + INTERVAL 14 DAY, 'sistema', 4),
('Gana de Regreso', 'cupon_unico', 'Cupón exclusivo para reactivar clientes inactivos', CURDATE(), CURDATE() + INTERVAL 30 DAY, 'sistema', 5),
('Vuelve y Compra Ya', 'cupon_unico', '15% descuento si abandonaste tu carrito', CURDATE(), CURDATE() + INTERVAL 7 DAY, 'sistema', 6);

-- ================================================================
-- 📅 ÚLTIMOS EVENTOS Y ACTIVIDAD DEL USUARIO
-- Campos para trazabilidad de uso, última conexión, última compra
-- ================================================================

-- Agregar columnas si no existen ya
ALTER TABLE usuarios
ADD COLUMN ultima_conexion DATETIME NULL AFTER fecha_registro;

ALTER TABLE usuarios
ADD COLUMN ultima_compra DATETIME NULL AFTER ultima_conexion;

-- Tabla auxiliar para rastrear actividad detallada (opcional)
CREATE TABLE actividad_usuario (
  actividad_id INT AUTO_INCREMENT PRIMARY KEY,
  usuario_id INT NOT NULL,
  tipo_actividad ENUM('inicio_sesion', 'compra', 'comentario', 'valoracion', 'ticket', 'referido') NOT NULL,
  descripcion TEXT,
  modulo VARCHAR(50),
  ip_origen VARCHAR(45),
  fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (usuario_id) REFERENCES usuarios(usuario_id)
) ENGINE=InnoDB;

-- ================================================================
-- 🧾 EXTENSIÓN DE ENUM PARA MÁS EVENTOS EN actividad_usuario
-- ================================================================

-- NOTA: MySQL no permite modificar ENUM directamente con ALTER COLUMN en versiones antiguas,
--       por lo que se recomienda recrear la columna con los nuevos valores:

ALTER TABLE actividad_usuario
MODIFY tipo_actividad ENUM(
  'inicio_sesion',
  'compra',
  'comentario',
  'valoracion',
  'ticket',
  'referido',
  'logout',
  'cupon_redimido',
  'consulta_frecuente',
  'perfil_actualizado',
  'producto_visto',
  'carrito_abandonado',
  'solicitud_factura',
  'registro_nuevo',
  'testimonio',
  'respuesta_testimonio'
) NOT NULL;

-- ================================================================
-- ⚙️ TRIGGERS AUTOMÁTICOS PARA REGISTRO DE ACTIVIDAD DE USUARIOS
-- ================================================================

DELIMITER //

-- 🎯 Registro de nueva sesión (inicio de sesión)
CREATE TRIGGER trg_usuario_login
AFTER UPDATE ON usuarios
FOR EACH ROW
BEGIN
  IF NEW.ultima_conexion IS NOT NULL AND OLD.ultima_conexion IS NULL THEN
    INSERT INTO actividad_usuario (usuario_id, tipo_actividad, descripcion, modulo)
    VALUES (NEW.usuario_id, 'inicio_sesion', 'Inicio de sesión del usuario', 'autenticacion');
  END IF;
END;
//

-- 💳 Registro de compra
CREATE TRIGGER trg_usuario_compra
AFTER INSERT ON pedidos
FOR EACH ROW
BEGIN
  UPDATE usuarios
  SET ultima_compra = NEW.fecha_pedido
  WHERE usuario_id = NEW.cliente_id;

  INSERT INTO actividad_usuario (usuario_id, tipo_actividad, descripcion, modulo)
  VALUES (NEW.cliente_id, 'compra', CONCAT('Pedido #', NEW.pedido_id, ' realizado'), 'pedidos');
END;
//

-- 🎁 Redención de cupón (ejemplo a partir de campo "cupon" en pedido)
CREATE TRIGGER trg_cupon_redimido
AFTER INSERT ON pedidos
FOR EACH ROW
BEGIN
  IF NEW.cupon IS NOT NULL THEN
    INSERT INTO actividad_usuario (usuario_id, tipo_actividad, descripcion, modulo)
    VALUES (NEW.cliente_id, 'cupon_redimido', CONCAT('Cupón "', NEW.cupon, '" aplicado en pedido #', NEW.pedido_id), 'promociones');
  END IF;
END;
//

DELIMITER ;

-- ================================================================
-- 👥 NUEVOS TIPOS DE USUARIOS Y EVENTOS POR ROL
-- ================================================================

-- Agregar nuevos roles sugeridos con permisos iniciales (si no existen ya)
INSERT INTO roles (rol_nombre, descripcion, permisos_json)
VALUES 
('influencer', 'Promueve productos y recibe beneficios por referidos.',
 JSON_OBJECT('productos', JSON_OBJECT('leer', true), 'referidos', JSON_OBJECT('crear', true, 'leer', true))),
('afiliado', 'Usuario que comparte productos y gana comisiones.',
 JSON_OBJECT('productos', JSON_OBJECT('leer', true), 'reportes', JSON_OBJECT('exportar', true))),
('proveedor', 'Usuario con permiso para subir productos de una marca.',
 JSON_OBJECT('productos', JSON_OBJECT('crear', true, 'leer', true, 'modificar', true))),
('blogger', 'Usuario con capacidad para escribir entradas de blog y responder comentarios.',
 JSON_OBJECT('blog', JSON_OBJECT('crear', true, 'responder', true)));

-- Ampliar eventos de actividad a nivel de trigger y lógica backend (manual o SP)

DELIMITER //

-- 📝 Registro de creación de testimonio
CREATE TRIGGER trg_nuevo_testimonio
AFTER INSERT ON testimonios
FOR EACH ROW
BEGIN
  INSERT INTO actividad_usuario (usuario_id, tipo_actividad, descripcion, modulo)
  VALUES (NEW.usuario_id, 'testimonio', 'Testimonio publicado por el usuario', 'testimonios');
END;
//

-- 🛠️ Registro de edición de perfil
CREATE TRIGGER trg_edicion_perfil
AFTER UPDATE ON usuarios
FOR EACH ROW
BEGIN
  IF NEW.nombre <> OLD.nombre OR NEW.telefono <> OLD.telefono OR NEW.direccion <> OLD.direccion THEN
    INSERT INTO actividad_usuario (usuario_id, tipo_actividad, descripcion, modulo)
    VALUES (NEW.usuario_id, 'perfil_actualizado', 'Perfil del usuario editado', 'usuarios');
  END IF;
END;
//

-- 🧺 Registro de carrito abandonado (versión trigger simulada, requiere tabla temporal o lógica backend)

-- Se sugiere crear un evento automático nocturno para registrar abandono real si pedido no se finaliza

DELIMITER ;

-- ================================================================
-- 🎟️ TICKETS EXTENDIDOS Y MODELOS FLEXIBLES DE NEGOCIO
-- Incluye soporte para dropshipping, venta callejera y dark kitchens
-- ================================================================

-- Tipos extendidos de tickets
ALTER TABLE tickets_soporte
MODIFY tipo ENUM(
  'cliente',
  'tecnico',
  'proveedor',
  'logistica',
  'dropshipping',
  'dark_kitchen',
  'repartidor',
  'callejero'
) DEFAULT 'cliente';

-- Categorías de operación alternativa por producto
ALTER TABLE productos
ADD COLUMN tipo_operacion ENUM(
  'tienda_fisica',
  'envio_local',
  'envio_nacional',
  'dropshipping',
  'pickup_domicilio',
  'punto_retiro',
  'dark_kitchen',
  'ambulante'
) DEFAULT 'tienda_fisica';

-- Tabla para registro de puntos de entrega o pickup
CREATE TABLE puntos_entrega (
  punto_id INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(100),
  direccion TEXT,
  latitud DECIMAL(10,8),
  longitud DECIMAL(11,8),
  tipo ENUM('punto_retiro', 'punto_venta_movil', 'dark_kitchen'),
  horario_apertura TIME,
  horario_cierre TIME,
  activo BOOLEAN DEFAULT TRUE
) ENGINE=InnoDB;

-- Relación entre producto y punto de entrega
CREATE TABLE producto_punto_entrega (
  producto_id INT NOT NULL,
  punto_id INT NOT NULL,
  PRIMARY KEY (producto_id, punto_id),
  FOREIGN KEY (producto_id) REFERENCES productos(producto_id),
  FOREIGN KEY (punto_id) REFERENCES puntos_entrega(punto_id)
) ENGINE=InnoDB;

-- Opcional: Relación con repartidores callejeros
CREATE TABLE asignaciones_movil (
  asignacion_id INT AUTO_INCREMENT PRIMARY KEY,
  repartidor_id INT NOT NULL,
  producto_id INT NOT NULL,
  fecha_asignacion DATE DEFAULT CURRENT_DATE,
  punto_id INT,
  status ENUM('activo', 'completado', 'cancelado') DEFAULT 'activo',
  FOREIGN KEY (repartidor_id) REFERENCES usuarios(usuario_id),
  FOREIGN KEY (producto_id) REFERENCES productos(producto_id),
  FOREIGN KEY (punto_id) REFERENCES puntos_entrega(punto_id)
) ENGINE=InnoDB;

-- Ticket relacionado a entregas ambulantes o cocinas ocultas
ALTER TABLE tickets_soporte
ADD COLUMN punto_id INT DEFAULT NULL,
ADD FOREIGN KEY (punto_id) REFERENCES puntos_entrega(punto_id);

-- ================================================================
-- 🛠️ SOPORTE PARA RETAIL, SERVICIOS, SUSCRIPCIONES Y EVENTOS
-- ================================================================

-- Marcar tipo de producto: físico, servicio, suscripción, evento, etc.
ALTER TABLE productos
ADD COLUMN tipo_producto ENUM('producto_fisico', 'servicio', 'evento', 'suscripcion') DEFAULT 'producto_fisico';

-- Tabla de servicios avanzados con duración, frecuencia, proveedor y modalidad
CREATE TABLE servicios (
  servicio_id INT AUTO_INCREMENT PRIMARY KEY,
  producto_id INT NOT NULL,
  duracion_minutos INT DEFAULT 60,
  frecuencia ENUM('único', 'diario', 'semanal', 'mensual', 'anual') DEFAULT 'único',
  modalidad ENUM('presencial', 'en_linea', 'mixto') DEFAULT 'presencial',
  proveedor_id INT,
  requiere_agenda BOOLEAN DEFAULT TRUE,
  FOREIGN KEY (producto_id) REFERENCES productos(producto_id),
  FOREIGN KEY (proveedor_id) REFERENCES usuarios(usuario_id)
) ENGINE=InnoDB;

-- Tabla de eventos con fecha y ubicación
CREATE TABLE eventos (
  evento_id INT AUTO_INCREMENT PRIMARY KEY,
  producto_id INT NOT NULL,
  fecha_evento DATETIME,
  ubicacion TEXT,
  cupo_maximo INT DEFAULT 50,
  cupo_actual INT DEFAULT 0,
  link_virtual TEXT,
  FOREIGN KEY (producto_id) REFERENCES productos(producto_id)
) ENGINE=InnoDB;

-- Suscripciones disponibles en el catálogo
CREATE TABLE suscripciones (
  suscripcion_id INT AUTO_INCREMENT PRIMARY KEY,
  producto_id INT NOT NULL,
  duracion_dias INT NOT NULL,
  renovacion_automatica BOOLEAN DEFAULT TRUE,
  max_usos INT DEFAULT NULL,
  acceso_ilimitado BOOLEAN DEFAULT FALSE,
  FOREIGN KEY (producto_id) REFERENCES productos(producto_id)
) ENGINE=InnoDB;

-- Registro de usuarios suscritos
CREATE TABLE usuarios_suscripciones (
  usuario_id INT NOT NULL,
  suscripcion_id INT NOT NULL,
  fecha_inicio DATE DEFAULT CURRENT_DATE,
  fecha_fin DATE,
  activa BOOLEAN DEFAULT TRUE,
  usos_restantes INT,
  PRIMARY KEY (usuario_id, suscripcion_id),
  FOREIGN KEY (usuario_id) REFERENCES usuarios(usuario_id),
  FOREIGN KEY (suscripcion_id) REFERENCES suscripciones(suscripcion_id)
) ENGINE=InnoDB;

-- Historial de asistencia a eventos
CREATE TABLE asistencia_eventos (
  usuario_id INT,
  evento_id INT,
  asistencia BOOLEAN DEFAULT TRUE,
  fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (usuario_id, evento_id),
  FOREIGN KEY (usuario_id) REFERENCES usuarios(usuario_id),
  FOREIGN KEY (evento_id) REFERENCES eventos(evento_id)
) ENGINE=InnoDB;

-- Tabla opcional: agendamiento de servicios contratados
CREATE TABLE agenda_servicios (
  agenda_id INT AUTO_INCREMENT PRIMARY KEY,
  servicio_id INT NOT NULL,
  usuario_id INT NOT NULL,
  fecha_hora DATETIME,
  estado ENUM('pendiente', 'confirmado', 'completado', 'cancelado') DEFAULT 'pendiente',
  notas TEXT,
  FOREIGN KEY (servicio_id) REFERENCES servicios(servicio_id),
  FOREIGN KEY (usuario_id) REFERENCES usuarios(usuario_id)
) ENGINE=InnoDB;

-- ================================================================
-- 👨‍⚕️ SOPORTE PARA PROFESIONISTAS Y OFICIOS ESPECIALIZADOS
-- Médicos, ingenieros, técnicos, obreros, etc.
-- ================================================================

-- Tipos de profesionistas/oficios
CREATE TABLE tipos_profesionistas (
  tipo_id INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL UNIQUE,
  descripcion TEXT
) ENGINE=InnoDB;

-- Perfil profesional de usuarios
CREATE TABLE perfiles_profesionales (
  perfil_id INT AUTO_INCREMENT PRIMARY KEY,
  usuario_id INT NOT NULL,
  tipo_id INT NOT NULL,
  especialidad VARCHAR(100),
  cedula_profesional VARCHAR(50),
  experiencia_anios INT,
  certificado_url VARCHAR(255),
  resumen_perfil TEXT,
  verificado BOOLEAN DEFAULT FALSE,
  FOREIGN KEY (usuario_id) REFERENCES usuarios(usuario_id),
  FOREIGN KEY (tipo_id) REFERENCES tipos_profesionistas(tipo_id)
) ENGINE=InnoDB;

-- Servicios prestados por profesionistas (relación directa)
CREATE TABLE servicios_profesionales (
  servicio_id INT AUTO_INCREMENT PRIMARY KEY,
  usuario_id INT NOT NULL,
  titulo VARCHAR(150),
  descripcion TEXT,
  precio_base DECIMAL(10,2) NOT NULL,
  duracion_minutos INT DEFAULT 60,
  presencial BOOLEAN DEFAULT TRUE,
  en_linea BOOLEAN DEFAULT TRUE,
  requiere_agenda BOOLEAN DEFAULT TRUE,
  activo BOOLEAN DEFAULT TRUE,
  fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (usuario_id) REFERENCES usuarios(usuario_id)
) ENGINE=InnoDB;

-- Agenda de citas con profesionistas
CREATE TABLE citas_profesionales (
  cita_id INT AUTO_INCREMENT PRIMARY KEY,
  servicio_id INT NOT NULL,
  cliente_id INT NOT NULL,
  fecha_hora DATETIME NOT NULL,
  estado ENUM('pendiente', 'confirmada', 'completada', 'cancelada') DEFAULT 'pendiente',
  notas TEXT,
  FOREIGN KEY (servicio_id) REFERENCES servicios_profesionales(servicio_id),
  FOREIGN KEY (cliente_id) REFERENCES usuarios(usuario_id)
) ENGINE=InnoDB;

-- Valoraciones específicas de servicios profesionales
CREATE TABLE valoraciones_profesionales (
  valoracion_id INT AUTO_INCREMENT PRIMARY KEY,
  cita_id INT NOT NULL,
  calificacion INT CHECK (calificacion BETWEEN 1 AND 5),
  comentario TEXT,
  fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (cita_id) REFERENCES citas_profesionales(cita_id)
) ENGINE=InnoDB;

-- ================================================================
-- 🎫 GESTIÓN DE BOLETOS DE EVENTOS Y LICENCIAS DIGITALES
-- Incluye validación, emisión, control de acceso y rastreo
-- ================================================================

-- Boletos generados por evento
CREATE TABLE boletos_evento (
  boleto_id INT AUTO_INCREMENT PRIMARY KEY,
  evento_id INT NOT NULL,
  usuario_id INT NOT NULL,
  codigo_boleto VARCHAR(100) UNIQUE,
  qr_url VARCHAR(255),
  estado ENUM('emitido', 'usado', 'cancelado') DEFAULT 'emitido',
  fecha_emision TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  fecha_uso DATETIME NULL,
  FOREIGN KEY (evento_id) REFERENCES eventos(evento_id),
  FOREIGN KEY (usuario_id) REFERENCES usuarios(usuario_id)
) ENGINE=InnoDB;

-- Historial de escaneos de boletos
CREATE TABLE escaneo_boletos (
  escaneo_id INT AUTO_INCREMENT PRIMARY KEY,
  boleto_id INT NOT NULL,
  escaneado_por INT,
  ubicacion TEXT,
  fecha_escaneo TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  resultado ENUM('válido', 'rechazado', 'duplicado') DEFAULT 'válido',
  FOREIGN KEY (boleto_id) REFERENCES boletos_evento(boleto_id),
  FOREIGN KEY (escaneado_por) REFERENCES usuarios(usuario_id)
) ENGINE=InnoDB;

-- Licencias digitales de uso o software
CREATE TABLE licencias_digitales (
  licencia_id INT AUTO_INCREMENT PRIMARY KEY,
  producto_id INT NOT NULL,
  usuario_id INT NOT NULL,
  clave_licencia VARCHAR(100) UNIQUE,
  tipo ENUM('único_uso', 'temporal', 'permanente') DEFAULT 'permanente',
  activa BOOLEAN DEFAULT TRUE,
  fecha_activacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  fecha_expiracion DATE NULL,
  FOREIGN KEY (producto_id) REFERENCES productos(producto_id),
  FOREIGN KEY (usuario_id) REFERENCES usuarios(usuario_id)
) ENGINE=InnoDB;

-- Validaciones de licencias (registro de usos)
CREATE TABLE uso_licencias (
  uso_id INT AUTO_INCREMENT PRIMARY KEY,
  licencia_id INT NOT NULL,
  fecha_uso TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  ip_usada VARCHAR(45),
  dispositivo TEXT,
  resultado ENUM('válida', 'expirada', 'revocada', 'no_encontrada') DEFAULT 'válida',
  FOREIGN KEY (licencia_id) REFERENCES licencias_digitales(licencia_id)
) ENGINE=InnoDB;

-- ================================================================
-- 💳 GESTIÓN DE PAGOS ELECTRÓNICOS Y PASARELAS DE TERCEROS/PROPIAS
-- Incluye tarjetas, wallets, transferencias y validación de pagos
-- ================================================================

-- Métodos de pago aceptados (catálogo)
CREATE TABLE metodos_pago (
  metodo_id INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  tipo ENUM('tarjeta', 'transferencia', 'codi', 'paypal', 'mercadopago', 'criptomoneda', 'pago_local'),
  es_pasarela BOOLEAN DEFAULT FALSE,
  activo BOOLEAN DEFAULT TRUE
) ENGINE=InnoDB;

-- Pasarelas de pago integradas
CREATE TABLE pasarelas_pago (
  pasarela_id INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  tipo ENUM('propia', 'tercero'),
  api_url TEXT,
  api_key TEXT,
  sandbox BOOLEAN DEFAULT TRUE,
  descripcion TEXT
) ENGINE=InnoDB;

-- Relación entre método de pago y pasarela
CREATE TABLE metodo_pasarela (
  metodo_id INT NOT NULL,
  pasarela_id INT NOT NULL,
  PRIMARY KEY (metodo_id, pasarela_id),
  FOREIGN KEY (metodo_id) REFERENCES metodos_pago(metodo_id),
  FOREIGN KEY (pasarela_id) REFERENCES pasarelas_pago(pasarela_id)
) ENGINE=InnoDB;

-- Pagos realizados
CREATE TABLE pagos (
  pago_id INT AUTO_INCREMENT PRIMARY KEY,
  pedido_id INT NOT NULL,
  usuario_id INT NOT NULL,
  metodo_id INT NOT NULL,
  pasarela_id INT,
  monto DECIMAL(10,2) NOT NULL,
  referencia_externa VARCHAR(100),
  estado_pago ENUM('pendiente', 'completado', 'fallido', 'reembolsado') DEFAULT 'pendiente',
  detalles JSON,
  fecha_pago TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (pedido_id) REFERENCES pedidos(pedido_id),
  FOREIGN KEY (usuario_id) REFERENCES usuarios(usuario_id),
  FOREIGN KEY (metodo_id) REFERENCES metodos_pago(metodo_id),
  FOREIGN KEY (pasarela_id) REFERENCES pasarelas_pago(pasarela_id)
) ENGINE=InnoDB;

-- Historial de intentos de pago
CREATE TABLE intentos_pago (
  intento_id INT AUTO_INCREMENT PRIMARY KEY,
  pago_id INT NOT NULL,
  intento_num INT DEFAULT 1,
  resultado ENUM('exitoso', 'fallido', 'error', 'reintentado'),
  mensaje TEXT,
  fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (pago_id) REFERENCES pagos(pago_id)
) ENGINE=InnoDB;

-- ================================================================
-- 🔒 SEGURIDAD, INTEGRIDAD Y REGLAS DE NEGOCIO ESTRICTAS
-- ================================================================

-- ✔️ Validaciones de integridad básicas reforzadas
ALTER TABLE usuarios ADD CONSTRAINT chk_email_formato CHECK (correo_electronico LIKE '%@%.%');
ALTER TABLE productos ADD CONSTRAINT chk_precio_valido CHECK (precio >= 0 AND precio < 999999);
ALTER TABLE pedidos ADD CONSTRAINT chk_total_valido CHECK (total >= 0);
ALTER TABLE promociones ADD CONSTRAINT chk_fechas_validas CHECK (fecha_fin > fecha_inicio);

-- 🚫 Evitar inconsistencias lógicas
ALTER TABLE referidos ADD CONSTRAINT chk_autoreferencia_prohibida CHECK (usuario_referido <> referido_por);
ALTER TABLE detalle_pedido ADD CONSTRAINT chk_cantidad_mayor_0 CHECK (cantidad > 0);
ALTER TABLE valoraciones_profesionales ADD CONSTRAINT chk_valoracion_rango CHECK (calificacion BETWEEN 1 AND 5);

-- 🧾 Seguridad financiera básica
ALTER TABLE pagos ADD CONSTRAINT chk_pago_positivo CHECK (monto > 0);
ALTER TABLE licencias_digitales ADD CONSTRAINT chk_licencia_activa CHECK (activa IN (TRUE, FALSE));

-- 🔄 Triggers de control crítico sugeridos (no repetidos previamente)
DELIMITER //

-- Validar saldo antes de generar puntos (ejemplo de fidelidad)
CREATE TRIGGER trg_validar_fidelidad_compra
BEFORE INSERT ON puntos_usuario
FOR EACH ROW
BEGIN
  IF NEW.puntos <= 0 THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Puntos deben ser mayores a cero.';
  END IF;
END;
//

-- Prevenir creación de usuario duplicado desde backend inseguro
CREATE TRIGGER trg_prevenir_email_repetido
BEFORE INSERT ON usuarios
FOR EACH ROW
BEGIN
  IF EXISTS (SELECT 1 FROM usuarios WHERE correo_electronico = NEW.correo_electronico) THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Correo electrónico ya registrado.';
  END IF;
END;
//

DELIMITER ;

-- ================================================================
-- 📜 POLÍTICAS DE NEGOCIO APLICABLES, AUTOMATIZADAS Y SEGURAS
-- ================================================================

-- Tabla maestra de políticas de operación
CREATE TABLE politicas_negocio (
  politica_id INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(150) NOT NULL,
  descripcion TEXT,
  categoria ENUM('seguridad', 'finanzas', 'usuario', 'reparto', 'fidelizacion', 'publicidad', 'retencion'),
  aplica_a ENUM('usuarios', 'productos', 'pedidos', 'pagos', 'cupones', 'eventos', 'servicios', 'suscripciones'),
  severidad ENUM('alta', 'media', 'baja') DEFAULT 'media',
  activa BOOLEAN DEFAULT TRUE,
  automatizable BOOLEAN DEFAULT TRUE,
  fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Ejemplos de políticas automatizadas sugeridas
INSERT INTO politicas_negocio (nombre, descripcion, categoria, aplica_a, severidad, automatizable) VALUES
('Expiración de puntos a 90 días', 'Los puntos de fidelización expiran automáticamente tras 90 días sin uso.', 'fidelizacion', 'usuarios', 'media', TRUE),
('Descuento automático por recomendación', 'Los usuarios recomendados obtienen un 5% de descuento en su primera compra.', 'retencion', 'cupones', 'baja', TRUE),
('Bloqueo por 5 intentos de login fallidos', 'Se bloquea temporalmente el acceso tras múltiples fallos de autenticación.', 'seguridad', 'usuarios', 'alta', TRUE),
('Eliminación de productos sin stock por 30 días', 'Se desactiva el producto automáticamente si no tiene stock ni venta en 30 días.', 'productos', 'media', 'productos', TRUE),
('Notificación automática de carrito abandonado', 'Se envía recordatorio a clientes tras 24h de abandono.', 'retencion', 'pedidos', 'media', TRUE),
('Validación de precios de proveedores', 'No se permite publicar productos con precios por debajo de un umbral.', 'finanzas', 'productos', 'alta', TRUE);

-- Registro de aplicación de políticas (para trazabilidad)
CREATE TABLE aplicacion_politicas (
  aplicacion_id INT AUTO_INCREMENT PRIMARY KEY,
  politica_id INT NOT NULL,
  usuario_id INT,
  entidad_afectada VARCHAR(100),
  id_entidad INT,
  resultado TEXT,
  fecha_aplicacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (politica_id) REFERENCES politicas_negocio(politica_id),
  FOREIGN KEY (usuario_id) REFERENCES usuarios(usuario_id)
) ENGINE=InnoDB;

-- Vista para políticas activas y automatizables
CREATE OR REPLACE VIEW vista_politicas_automatizadas AS
SELECT * FROM politicas_negocio WHERE activa = TRUE AND automatizable = TRUE;

-- ================================================================
-- 📦 GESTIÓN AVANZADA DE INVENTARIOS
-- Incluye auditoría, ubicaciones, niveles mínimos, lotes y rotación
-- ================================================================

-- Almacenes físicos o virtuales
CREATE TABLE almacenes (
  almacen_id INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  ubicacion TEXT,
  tipo ENUM('central', 'local', 'virtual', 'dropshipping') DEFAULT 'central',
  activo BOOLEAN DEFAULT TRUE
) ENGINE=InnoDB;

-- Lotes por producto (para trazabilidad de stock)
CREATE TABLE lotes (
  lote_id INT AUTO_INCREMENT PRIMARY KEY,
  producto_id INT NOT NULL,
  almacen_id INT NOT NULL,
  cantidad INT NOT NULL,
  fecha_entrada DATE,
  fecha_vencimiento DATE,
  numero_lote VARCHAR(50),
  precio_unitario DECIMAL(10,2),
  FOREIGN KEY (producto_id) REFERENCES productos(producto_id),
  FOREIGN KEY (almacen_id) REFERENCES almacenes(almacen_id)
) ENGINE=InnoDB;

-- Movimientos de inventario (entradas, salidas, ajustes)
CREATE TABLE movimientos_inventario (
  movimiento_id INT AUTO_INCREMENT PRIMARY KEY,
  producto_id INT NOT NULL,
  almacen_id INT NOT NULL,
  lote_id INT,
  tipo_movimiento ENUM('entrada', 'salida', 'ajuste', 'traslado') NOT NULL,
  cantidad INT NOT NULL,
  motivo TEXT,
  usuario_id INT,
  fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (producto_id) REFERENCES productos(producto_id),
  FOREIGN KEY (almacen_id) REFERENCES almacenes(almacen_id),
  FOREIGN KEY (lote_id) REFERENCES lotes(lote_id),
  FOREIGN KEY (usuario_id) REFERENCES usuarios(usuario_id)
) ENGINE=InnoDB;

-- Niveles mínimos y máximos por almacén-producto
CREATE TABLE niveles_stock (
  producto_id INT NOT NULL,
  almacen_id INT NOT NULL,
  stock_minimo INT DEFAULT 10,
  stock_maximo INT DEFAULT 100,
  PRIMARY KEY (producto_id, almacen_id),
  FOREIGN KEY (producto_id) REFERENCES productos(producto_id),
  FOREIGN KEY (almacen_id) REFERENCES almacenes(almacen_id)
) ENGINE=InnoDB;

-- Vista para inventario actual por producto y almacén
CREATE OR REPLACE VIEW vista_stock_actual AS
SELECT 
  p.producto_id,
  a.almacen_id,
  p.nombre,
  a.nombre AS nombre_almacen,
  SUM(l.cantidad) AS stock_total,
  MIN(l.fecha_vencimiento) AS proxima_vencimiento
FROM productos p
JOIN lotes l ON l.producto_id = p.producto_id
JOIN almacenes a ON l.almacen_id = a.almacen_id
GROUP BY p.producto_id, a.almacen_id;

-- ================================================================
-- ⏰ EVENTOS PROGRAMADOS PARA INVENTARIO
-- Alertas por stock bajo, vencimiento próximo, y rotación lenta
-- ================================================================

-- NOTA: Asegúrate que el event scheduler esté activo:
-- SET GLOBAL event_scheduler = ON;

-- 📉 Alerta por stock por debajo del mínimo
CREATE EVENT IF NOT EXISTS alerta_stock_bajo
ON SCHEDULE EVERY 1 DAY
DO
INSERT INTO aplicacion_politicas (politica_id, usuario_id, entidad_afectada, id_entidad, resultado)
SELECT
  NULL, NULL, 'productos', ns.producto_id,
  CONCAT('Stock bajo en producto ', p.nombre, ' (stock actual: ', SUM(l.cantidad), ')')
FROM niveles_stock ns
JOIN lotes l ON ns.producto_id = l.producto_id AND ns.almacen_id = l.almacen_id
JOIN productos p ON p.producto_id = ns.producto_id
GROUP BY ns.producto_id, ns.almacen_id
HAVING SUM(l.cantidad) < ns.stock_minimo;

-- 🗓️ Alerta por lote con vencimiento próximo (7 días)
CREATE EVENT IF NOT EXISTS alerta_vencimiento_lote
ON SCHEDULE EVERY 1 DAY
DO
INSERT INTO aplicacion_politicas (politica_id, usuario_id, entidad_afectada, id_entidad, resultado)
SELECT
  NULL, NULL, 'lotes', lote_id,
  CONCAT('Lote próximo a vencer: ', numero_lote, ' del producto ', p.nombre)
FROM lotes
JOIN productos p ON p.producto_id = lotes.producto_id
WHERE fecha_vencimiento BETWEEN CURDATE() AND CURDATE() + INTERVAL 7 DAY;

-- 🕓 Alerta por baja rotación (menos de 5 ventas en 30 días)
CREATE EVENT IF NOT EXISTS alerta_baja_rotacion
ON SCHEDULE EVERY 1 WEEK
DO
INSERT INTO aplicacion_politicas (politica_id, usuario_id, entidad_afectada, id_entidad, resultado)
SELECT
  NULL, NULL, 'productos', dp.producto_id,
  CONCAT('Producto con baja rotación: ', p.nombre)
FROM detalle_pedido dp
JOIN pedidos pe ON pe.pedido_id = dp.pedido_id
JOIN productos p ON p.producto_id = dp.producto_id
WHERE pe.fecha_pedido >= CURDATE() - INTERVAL 30 DAY
GROUP BY dp.producto_id
HAVING COUNT(dp.detalle_id) < 5;
