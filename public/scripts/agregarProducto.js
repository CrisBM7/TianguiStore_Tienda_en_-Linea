/**
 * Archivo: agregarProducto.js
 * Descripción:
 * Este archivo contiene la lógica para la adición de productos a la tienda en línea TianguiStore.
 * Permite agregar un nuevo producto a través de un formulario, manejar las categorías y marcas desde la API, 
 * y visualizar vistas previas de las imágenes y modelos 3D.
 * 
 * Autor: I.S.C. Erick Renato Vega Ceron
 * Fecha de Creación: Mayo 2025
 */

document.addEventListener("DOMContentLoaded", () => {
  // Cargar categorías, marcas y configurar vistas previas de imágenes y modelos 3D
  //cargarCategorias();
  //cargarMarcas();
  configurarVistaPreviaImagenes();
  configurarVistaPreviaModelo3D();

  // Obtener el formulario de agregar producto
  const form = document.getElementById("form-agregar-producto");

  // Manejo del evento de envío del formulario
  form.addEventListener("submit", async (e) => {
    e.preventDefault(); // Prevenir el comportamiento por defecto (recarga de la página)

    const formData = new FormData();

    console.log(document.getElementById("nombre").value.trim());

    // 📦 Campos simples: recoger los valores del formulario y agregarlos al FormData
    formData.append("nombre", document.getElementById("nombre").value.trim());
    formData.append("descripcion", document.getElementById("descripcion").value.trim());
    formData.append("precio", document.getElementById("precio").value);
    formData.append("stock", document.getElementById("stock").value);
    formData.append("categoria_id", 1);
    formData.append("marca_id", 1);
    formData.append("tipo_pago", document.getElementById("tipo_pago").value);
    formData.append("publicado", document.getElementById("publicado").checked);
    formData.append("meses_sin_intereses", document.getElementById("meses_sin_intereses").checked);

    const nombre = document.getElementById("nombre");
    const descripcion = document.getElementById("descripcion");
    const precio = document.getElementById("precio");
    const stock = document.getElementById("stock");
    const categoria_id = document.getElementById("categoria_id");
    const marca_id = document.getElementById("marca_id");
    const tipo_pago = document.getElementById("tipo_pago");
    const publicado = document.getElementById("publicado");
    const meses_sin_intereses = document.getElementById("meses_sin_intereses");

    slugProductoAutogenerado = [...Array(10)]
    .map(() => Math.random().toString(36)[2]) // base36 da letras y números
    .join('');

    console.log("Este es el slug producto autogenerado: "+ slugProductoAutogenerado);

    let imagenC = "imagenes\\productos\\" + nombre.value.trim() +".jpg";

    const datos = {
      nombre: nombre.value.trim(),
      descripcion: descripcion.value.trim(),
      precio: precio.value.trim(),
      stock: stock.value,
      categoria_id: 1,
      marca_id: marca_id.value.trim() || null,
      tipo_pago: tipo_pago.value.trim() || null,
      publicado: publicado.value.trim(),
      meses_sin_intereses: meses_sin_intereses.value.trim(),
      proveedor_id: 1,
      slug_producto: slugProductoAutogenerado,
      imagen_url: imagenC
    };


    // 🖼️ Imágenes múltiples: Agregar todas las imágenes seleccionadas al FormData
    const imagenes = document.getElementById("imagenes").files;
    for (let i = 0; i < imagenes.length; i++) {
      formData.append("imagenes", imagenes[i]);
    }

    // 🧩 Modelo 3D (opcional): Agregar el archivo del modelo 3D si está presente
    const modelo3d = document.getElementById("modelo3d").files[0];
    if (modelo3d) {
      formData.append("modelo3d", modelo3d);
    }
    // Enviar los datos al servidor
    try {
      console.log("Agregar producto")
      const res = await fetch("/productos", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(datos)
      });
      const data = await res.json();
      console.log(res);

      // Manejo de respuesta exitosa o error
      if (!res.ok) {
        mostrarToast("❌ Error: " + (data.message || "No se pudo guardar el producto."), "danger");
        return;
      }

      mostrarToast("✅ Producto guardado exitosamente.", "success");

      // Limpiar el formulario y las vistas previas
      form.reset();
      document.getElementById("preview-imagenes").innerHTML = "";
      document.getElementById("preview-modelo3d").innerHTML = "";

    } catch (error) {
      console.error("Error al guardar producto:", error);
      mostrarToast("❌ Error de red o servidor.", "danger");
    }
  });
});

// 🔄 Cargar categorías desde API
async function cargarCategorias() {
  try {
    const res = await fetch("/categorias");
    const categorias = await res.json();
    const select = document.getElementById("categoria_id");
    select.innerHTML = '<option value="">Selecciona una categoría</option>';
    categorias.forEach(c => {
      const option = document.createElement("option");
      option.value = c.categoria_id;
      option.textContent = c.nombre;
      select.appendChild(option);
    });
  } catch {
    mostrarToast("⚠️ Error al cargar categorías.", "warning");
  }
}

// 🔄 Cargar marcas desde API
async function cargarMarcas() {
  try {
    const res = await fetch("/marcas");
    const marcas = await res.json();
    const select = document.getElementById("marca_id");
    select.innerHTML = '<option value="">Selecciona una marca</option>';
    marcas.forEach(m => {
      const option = document.createElement("option");
      option.value = m.marca_id;
      option.textContent = m.nombre;
      select.appendChild(option);
    });
  } catch {
    mostrarToast("⚠️ Error al cargar marcas.", "warning");
  }
}

// 🖼️ Vista previa de imágenes seleccionadas
function configurarVistaPreviaImagenes() {
  const input = document.getElementById("imagenes");
  const preview = document.getElementById("preview-imagenes");

  input.addEventListener("change", () => {
    preview.innerHTML = ""; // Limpiar cualquier vista previa previa
    const archivos = input.files;
    for (let i = 0; i < archivos.length; i++) {
      const reader = new FileReader();
      reader.onload = (e) => {
        const img = document.createElement("img");
        img.src = e.target.result;
        img.className = "img-thumbnail";
        img.style.height = "80px";
        img.style.marginRight = "10px";
        preview.appendChild(img);
      };
      reader.readAsDataURL(archivos[i]);
    }
  });
}

// 🔍 Vista previa del modelo 3D (si se carga un archivo .glb o .gltf)
function configurarVistaPreviaModelo3D() {
  const input = document.getElementById("modelo3d");
  const preview = document.getElementById("preview-modelo3d");

  input.addEventListener("change", () => {
    preview.innerHTML = ""; // Limpiar la vista previa previa
    const archivo = input.files[0];
    if (archivo && /\.(glb|gltf)$/i.test(archivo.name)) {
      const url = URL.createObjectURL(archivo);
      const modelViewer = document.createElement("model-viewer");
      modelViewer.setAttribute("src", url);
      modelViewer.setAttribute("camera-controls", "");
      modelViewer.setAttribute("auto-rotate", "");
      modelViewer.setAttribute("style", "width: 100%; height: 300px;");
      preview.appendChild(modelViewer);
    } else {
      preview.innerHTML = "<small class='text-muted'>Modelo no compatible para vista previa.</small>";
    }
  });
}

// 🔔 Función para mostrar notificaciones (toast) en la interfaz
function mostrarToast(mensaje, tipo = "success") {
  const toastContainer = document.getElementById("toast-container");
  const toast = document.createElement("div");
  toast.className = `toast align-items-center text-white bg-${tipo} border-0 show shadow`;
  toast.setAttribute("role", "alert");
  toast.innerHTML = `
    <div class="d-flex">
      <div class="toast-body fw-bold">${mensaje}</div>
      <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast"></button>
    </div>
  `;
  toastContainer.appendChild(toast);
  setTimeout(() => toast.remove(), 4000); // Remover el toast después de 4 segundos
}
