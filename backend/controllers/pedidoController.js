/**
 * 📁 CONTROLADOR: pedidoController.js
 * 📦 Módulo: Gestión de pedidos en TianguiStore usando procedimiento almacenado
 */

const pedidoModel = require("../models/pedido.model");

/**
 * 🧾 GET /pedidos
 * Obtener todos los pedidos del sistema (admin o gerente)
 */
exports.obtenerPedidos = async (req, res) => {
  try {
    const pedidos = await pedidoModel.obtenerPedidos();
    res.status(200).json(pedidos);
  } catch (error) {
    console.error("❌ Error al obtener pedidos:", error);
    res.status(500).json({ mensaje: "Error al obtener pedidos" });
  }
};

/**
 * 🧾 GET /mis-pedidos
 * Obtener pedidos del usuario autenticado
 */
exports.obtenerMisPedidos = async (req, res) => {
  const usuario = req.usuario;
  if (!usuario?.usuario_id) {
    return res.status(403).json({ mensaje: "No autenticado" });
  }
  console.log("Entro a la funcion obtener Pedidos");
  usuario = JSON.parse(req.body.usuario);
  console.log("Este es el objeto usuario: ", usuario);
  console.log("usuario id " + usuario.usuario_id);

  if (!usuario) return res.status(403).json({ mensaje: "No autenticado" });

  try {
    const pedidos = await pedidoModel.obtenerMisPedidos(usuario.usuario_id);
    console.log("Estos son los pedidos: " + pedidos);
    res.status(200).json(pedidos);
  } catch (error) {
    console.error("❌ Error al obtener pedidos del usuario:", error);
    res.status(500).json({ mensaje: "Error al obtener tus pedidos" });
  }
};

/**
 * ➕ POST /pedidos
 * Crear pedido completo desde el formulario del checkout
 */
exports.crearPedido = async (req, res) => {
  const usuario = req.usuario;
  if (!usuario?.usuario_id) {
    return res.status(403).json({ mensaje: "No autenticado" });
  }

  const {
    direccion_envio,
    metodo_pago,
    productos,
    cupon = null,
    comentarios = "",
    total: total_enviado
  } = req.body;

  if (!direccion_envio || !metodo_pago || !Array.isArray(productos) || productos.length === 0) {
    return res.status(400).json({
      mensaje: "Faltan campos requeridos: dirección, método de pago o productos"
    });
  }

  const productosValidos = productos.every(p =>
    p.producto_id && p.cantidad > 0 && !isNaN(parseFloat(p.precio_unitario))
  );

  if (!productosValidos) {
    return res.status(400).json({ mensaje: "Productos inválidos en el pedido" });
  console.log("Entro a crear el pedido");
  console.log(req.body);
  const usuario = req.body.usuario;
  //if (!usuario) return res.status(403).json({ mensaje: "No autenticado" });


  const { total, metodo_pago, cupon, direccion_envio, notas } = req.body;
  if (!total || !metodo_pago || !direccion_envio) {
    return res.status(400).json({ mensaje: "Faltan campos requeridos" });
  }

  try {
    const total_calculado = productos.reduce((sum, p) => sum + (p.cantidad * parseFloat(p.precio_unitario)), 0);

    if (parseFloat(total_enviado) !== total_calculado) {
      return res.status(400).json({ mensaje: "Total inconsistente con el detalle del pedido" });
    }

    const pedido_id = await pedidoModel.crearPedidoConSP({
      usuario_id: usuario.usuario_id,
      direccion_envio,
      metodo_pago,
      cupon,
      notas: comentarios,
      total: total_calculado,
      productos
    });

    res.status(201).json({ mensaje: "Pedido creado correctamente", pedido_id });

  } catch (error) {
    const mensajeCompleto = error?.message || "Error desconocido";
    const [mensajeUsuario, mensajeTecnico] = mensajeCompleto.split("|||");
    console.error("❌ Error técnico al crear pedido:", mensajeTecnico || mensajeCompleto);

    res.status(400).json({
      mensaje: mensajeUsuario?.trim() || "No se pudo crear el pedido. Intenta nuevamente."
    });
  }
};
}


/**
 * ➕ POST /api/makepp
 * Crear pedido desde formulario manual (con parámetros individuales).
 */
exports.crearPedidoProducto = async (req, res) => {
  console.log("Este es el body de mi PedidoProducto " + req.body);
  console.dir(req.body, { depth: null });
  let fkPedidoLocal = req.body.fk_pedidos;
  let fkProductosLocal = req.body.fk_productos;
  console.log(body.fk_pedidos);
  const pedidoProducto = await pedidoModel.crearPedidoProducto(
    {
      fkPedidos: fkPedidoLocal,
      fkProductos: fkProductosLocal
    }
  );
  
    res.status(201).json({ mensaje: "Pedidos producto creado correctamente", pedidoProducto });
};

/**
 * ➕ GET /api/pedidos informacion
 * Crear pedido desde formulario manual (con parámetros individuales).
 */

exports.getPedidoProducto = async (req, res) => {
  const { id } = req.params;
  console.log("Este es el id de el get PedidoProducto " + id);
  const pedidos = await pedidoModel.getPedidoProducto(id);
  //console.dir(pedidos[0], { depth: null });
  console.log("Resultado getPedidoProducto:  ", pedidos);
    res.status(201).json({ mensaje: "Get informacion correctamente", pedidos });
};



/**
 * 🛒 POST /pedidos/carrito
 * Crear pedido desde carrito persistido en base de datos
 */
exports.crearPedidoDesdeCarrito = async (req, res) => {
  const usuario = req.usuario;
  if (!usuario?.usuario_id) {
    return res.status(403).json({ mensaje: "No autenticado" });
  }

  const { direccion_envio, metodo_pago, cupon = null, comentarios = "" } = req.body;

  if (!direccion_envio || !metodo_pago) {
    return res.status(400).json({ mensaje: "Faltan campos requeridos: dirección o método de pago" });
  }

  //try {
    const productos = await pedidoModel.obtenerCarrito(usuario.usuario_id);

    if (!Array.isArray(productos) || productos.length === 0) {
      return res.status(400).json({ mensaje: "El carrito está vacío o no es válido" });
  //if (!usuario) return res.status(403).json({ mensaje: "No autenticado" });
  

  try {
    const totalCarrito = await pedidoModel.calcularTotalCarrito(usuario.usuario_id);
    if (totalCarrito <= 0) {
      return res.status(400).json({ mensaje: "El carrito está vacío o sin totales válidos" });
    }

    const { direccion_envio, metodo_pago, cupon, notas } = req.body;
    if (!direccion_envio || !metodo_pago) {
      return res.status(400).json({ mensaje: "Faltan datos para procesar el pedido" });
    }

    const total = productos.reduce((sum, p) => sum + p.cantidad * parseFloat(p.precio_unitario), 0);

    const pedido_id = await pedidoModel.crearPedidoConSP({
      usuario_id: usuario.usuario_id,
      direccion_envio,
      metodo_pago,
      cupon,
      notas: comentarios,
      total,
      productos
    });

    await pedidoModel.limpiarCarrito(usuario.usuario_id);

    res.status(201).json({ mensaje: "Pedido generado correctamente", pedido_id });

  } catch (error) {
    const mensajeCompleto = error?.message || "Error desconocido";
    const [mensajeUsuario, mensajeTecnico] = mensajeCompleto.split("|||");
    console.error("❌ Error técnico al generar pedido desde carrito:", mensajeTecnico || mensajeCompleto);

    res.status(400).json({
      mensaje: mensajeUsuario?.trim() || "No se pudo generar el pedido desde el carrito."
    });
  }
};

/**
 * ❌ PUT /pedidos/:id/cancelar
 * Cancelar un pedido si está pendiente y pertenece al usuario
 */
exports.cancelarPedido = async (req, res) => {
  const usuario = req.usuario;
  const pedido_id = req.params.id;

  if (!usuario?.usuario_id) {
    return res.status(403).json({ mensaje: "No autenticado" });
  }

  try {
    const pedido = await pedidoModel.obtenerPedidoPorId(pedido_id, usuario.usuario_id);
    if (!pedido) {
      return res.status(404).json({ mensaje: "Pedido no encontrado o no autorizado" });
    }

    if (![1, 2].includes(pedido.estado_id)) {
      return res.status(400).json({ mensaje: "El pedido ya no puede cancelarse" });
    }

    await pedidoModel.actualizarEstadoPedido(pedido_id, 6); // Estado 6 = Cancelado
    res.status(200).json({ mensaje: "Pedido cancelado correctamente" });
  } catch (error) {
    console.error("❌ Error al cancelar pedido:", error);
    res.status(500).json({ mensaje: "Error al cancelar el pedido" });
  }
};

/**
 * 📦 GET /pedidos/:id/productos
 * Obtener los productos de un pedido específico
 */
exports.obtenerProductosDelPedido = async (req, res) => {
  const usuario = req.usuario;
  const pedido_id = parseInt(req.params.id);

  if (!usuario?.usuario_id || isNaN(pedido_id)) {
    return res.status(400).json({ mensaje: "Solicitud inválida" });
  }

  try {
    const productos = await pedidoModel.obtenerProductosPorPedido(
      pedido_id,
      usuario.usuario_id,
      usuario.rol || "cliente"
    );

    if (!productos) {
      return res.status(403).json({ mensaje: "No autorizado para ver este pedido" });
    }

    res.status(200).json(productos);
  } catch (error) {
    console.error("❌ Error al obtener productos del pedido:", error);
    res.status(500).json({ mensaje: "Error al obtener productos del pedido" });
  }
};

/**
 * 🗂️ GET /admin/listado
 * Listar todos los pedidos (para administradores), con filtros y paginación
 */
exports.listarTodosLosPedidos = async (req, res) => {
  try {
    const { page = 1, limite = 30, estado, fecha_inicio, fecha_fin } = req.query;
    const offset = (page - 1) * limite;

    const pedidos = await pedidoModel.obtenerPedidosPaginadosYFiltrados({
      estado,
      fecha_inicio,
      fecha_fin,
      limite: parseInt(limite),
      offset: parseInt(offset)
    });

    res.status(200).json(pedidos);
  } catch (error) {
    console.error("❌ Error al listar todos los pedidos:", error);
    res.status(500).json({ mensaje: "No se pudieron obtener los pedidos." });
  }
};
}
