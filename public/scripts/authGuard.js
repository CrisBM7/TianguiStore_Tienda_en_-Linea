(() => {
  let timeoutRenovacion = null;

  /**
   * 🔐 Verifica si un token JWT ha expirado.
   * @param {string} token - Token JWT.
   * @returns {boolean} - true si está expirado o mal formado.
   */
  function tokenExpirado(token) {
    try {
      const payload = JSON.parse(atob(token.split(".")[1]));
      const ahora = Math.floor(Date.now() / 1000);
      return !payload.exp || payload.exp < ahora;
    } catch (e) {
      console.error("❌ Token inválido o corrupto:", e);
      return true;
    }
  }

  /**
   * 🔄 Solicita un nuevo token al backend antes de que expire.
   */
  async function renovarToken() {
    const token = localStorage.getItem("token");
    if (!token) return;

    try {
      const res = await fetch("/auth/renovar", {
        method: "POST",
        headers: {
          "Authorization": `Bearer ${token}`,
          "Content-Type": "application/json"
        }
      });

      if (!res.ok) {
        console.warn("🔐 Token no renovable. Finalizando sesión...");
        cerrarSesionSilenciosa();
        return;
      }

      const data = await res.json();
      localStorage.setItem("token", data.token);
      localStorage.setItem("usuario", JSON.stringify(data.usuario));

      console.log("✅ Token renovado correctamente.");
      clearTimeout(timeoutRenovacion);
      programarRenovacionToken();
    } catch (error) {
      console.error("❌ Error al renovar token:", error);
      cerrarSesionSilenciosa();
    }
  }

  /**
   * ⏳ Programa renovación automática del token 1 minuto antes de su expiración.
   */
  function programarRenovacionToken() {
    const token = localStorage.getItem("token");
    if (!token) return;

    try {
      const payload = JSON.parse(atob(token.split(".")[1]));
      const ahora = Math.floor(Date.now() / 1000);
      const segundosRestantes = payload.exp - ahora;
      const tiempoAntesDeRenovar = (segundosRestantes - 60) * 1000;

      if (tiempoAntesDeRenovar <= 0) {
        console.log("⚠️ Token próximo a expirar. Renovando ya...");
        renovarToken();
        return;
      }

      console.log(`⏱️ Renovación programada en ${(tiempoAntesDeRenovar / 1000 / 60).toFixed(1)} minutos`);
      timeoutRenovacion = setTimeout(renovarToken, tiempoAntesDeRenovar);
    } catch (e) {
      console.error("❌ Error al leer token para programación:", e);
      cerrarSesionSilenciosa();
    }
  }

  /**
   * 🚫 Elimina sesión local y redirige al login.
   */
  function cerrarSesionSilenciosa() {
    localStorage.removeItem("token");
    localStorage.removeItem("usuario");
    window.location.href = "/login.html";
  }

  /**
   * ✅ Verifica que haya sesión válida con estructura y permisos mínimos.
   * @returns {boolean}
   */
  function sesionValida() {
    const token = localStorage.getItem("token");
    const usuario = JSON.parse(localStorage.getItem("usuario") || "{}");

    const estructuraValida =
      usuario.usuario_id &&
      typeof usuario.rol === "string" &&
      typeof usuario.permisos === "object";

    const tienePermisos =
      usuario.permisos?.productos?.leer ||
      usuario.permisos?.usuarios?.leer;

    return token && !tokenExpirado(token) && estructuraValida && tienePermisos;
  }

  /**
   * 🎯 Punto de entrada: validación inicial de sesión.
   */
  document.addEventListener("DOMContentLoaded", () => {
    if (!sesionValida()) {
      console.warn("🚫 Sesión no válida o permisos insuficientes.");
      cerrarSesionSilenciosa();
      return;
    }

    programarRenovacionToken();
  });
})();
