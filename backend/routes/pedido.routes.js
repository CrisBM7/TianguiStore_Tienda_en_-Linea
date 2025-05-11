const express = require("express");
const router = express.Router();

const {
  obtenerPedidos,
  obtenerMisPedidos,
  crearPedido,
  cancelarPedido,
  crearPedidoProducto,
  crearPedidoDesdeCarrito,
  getPedidoProducto
} = require("../controllers/pedidoController");

const {
 //verificarAutenticacion,
  verificarPermiso
} = require("../middlewares/authMiddleware");

const validarResultados = require("../middlewares/validacion/validarResultados");
const pedidoSchema = require("../middlewares/validacion/pedidoSchema");


// 📦 Obtener todos los pedidos (solo admin o soporte)
router.get(
  "/",
 //verificarAutenticacion,
  verificarPermiso("pedidos", "leer"),
  obtenerPedidos
);

// 📦 Obtener solo los pedidos del usuario autenticado (cliente)
router.post(
  "/mis",
 //verificarAutenticacion,
  obtenerMisPedidos
);

// 🛒 Crear pedido desde productos directos
router.post(
  "/",
 //verificarAutenticacion,
  //verificarPermiso("pedidos", "crear"),
  pedidoSchema,
  validarResultados,
  crearPedido
);

//Crear relacion pedidos productos
router.post(
  "/makepp",
  //pedidoSchema,
  //validarResultados,
  crearPedidoProducto
);

 //Ruta para traer informacion de pedido producto
  router.get("/traerinfopedido/:id", async (req, res) => {
  try {
    console.log("entra a traerinfopedido")
    await getPedidoProducto(req, res);
  } catch (error) {
    console.error("❌ Error al enviar la informacion con el get:", error);
    res.status(500).json({ mensaje: "Error interno al mandar la informacion con el get." });
  }
});


// 🛍️ Crear pedido desde carrito del cliente
router.post(
  "/desde-carrito",
 //verificarAutenticacion,
  verificarPermiso("pedidos", "crear"),
  pedidoSchema,
  validarResultados,
  crearPedidoDesdeCarrito
);

// ❌ Cancelar un pedido (cliente propio o admin)
router.put(
  "/:id/cancelar",
 //verificarAutenticacion,
  verificarPermiso("pedidos", "cancelar"),
  cancelarPedido
);

module.exports = router;
