<template>
  <div class="space-y-5 fade-in select-none">

    <!-- Header -->
    <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
      <p class="text-sm text-slate-400">Administra tu catálogo de productos</p>
      <button @click="openModal()" class="btn btn-primary btn-sm w-full sm:w-auto">
        <PlusIcon class="w-4 h-4 inline-block mr-2" />
        Nuevo Producto
      </button>
    </div>

    <!-- Filter Bar -->
    <div class="card p-4">
      <div class="flex flex-wrap gap-3 items-center justify-between">
        <!-- Search & Category Filter Group -->
        <div class="flex flex-1 flex-wrap gap-3 min-w-[280px]">
          <!-- Search -->
          <div class="relative flex-1 min-w-[200px]">
            <span class="absolute inset-y-0 left-3 flex items-center text-slate-500 pointer-events-none">
              <SearchIcon class="w-4 h-4" />
            </span>
            <input
              type="text"
              v-model="searchQuery"
              placeholder="Buscar por nombre o código..."
              class="input w-full pl-9"
            />
          </div>

          <!-- Category select -->
          <select
            v-model="selectedCategory"
            class="input w-full sm:w-48"
          >
            <option value="">Todas las categorías</option>
            <option v-for="cat in categorias" :key="cat.id_categoria" :value="cat.id_categoria">
              {{ cat.nombre }}
            </option>
          </select>
        </div>

        <!-- Low stock toggle -->
        <button
          @click="toggleStockFilter"
          :class="[
            'btn btn-secondary btn-sm flex items-center gap-1.5 whitespace-nowrap w-full sm:w-auto justify-center',
            filterLowStock ? 'bg-amber-500/10 border-amber-500/30 text-amber-400' : ''
          ]"
        >
          <AlertTriangleIcon class="w-3.5 h-3.5" />
          Stock Bajo
        </button>
      </div>
    </div>

    <!-- Products Table -->
    <div class="card overflow-hidden">
      <!-- Loading -->
      <div v-if="loading" class="flex flex-col items-center justify-center py-20 gap-3 text-slate-500">
        <span class="w-8 h-8 border-2 border-sky-500/30 border-t-sky-500 rounded-full animate-spin"></span>
        <p class="text-xs">Cargando catálogo...</p>
      </div>

      <!-- Empty -->
      <div v-else-if="filteredProductos.length === 0" class="flex flex-col items-center justify-center py-20 gap-3 text-slate-500">
        <InboxIcon class="w-12 h-12 text-slate-700" />
        <p class="text-xs">No se encontraron productos en el catálogo</p>
      </div>

      <!-- Table -->
      <div v-else class="table-wrap">
        <table class="data-table">
          <thead>
            <tr>
              <th>Nombre / Código</th>
              <th>Categoría</th>
              <th>Stock</th>
              <th>P. Compra</th>
              <th>P. Venta</th>
              <th>Estado</th>
              <th class="text-right">Acciones</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="prod in filteredProductos" :key="prod.id_producto">
              <!-- Nombre / Código -->
              <td>
                <div>
                  <p class="font-semibold text-slate-100 text-sm">{{ prod.nombre }}</p>
                  <span class="flex items-center gap-1 text-xs text-slate-500 font-mono mt-0.5">
                    <BarcodeIcon class="w-3 h-3" />
                    {{ prod.codigo_barras || 'SIN CÓDIGO' }}
                  </span>
                </div>
              </td>

              <!-- Categoría -->
              <td class="text-slate-400">
                {{ prod.categoria?.nombre || 'Sin categoría' }}
              </td>

              <!-- Stock -->
              <td>
                <span
                  class="font-mono font-bold text-sm"
                  :class="
                    prod.stock_actual === 0 ? 'text-red-400' :
                    prod.stock_actual <= prod.stock_minimo ? 'text-amber-400' : 'text-emerald-400'
                  "
                >{{ prod.stock_actual }}</span>
                <p class="text-xs text-slate-500 mt-0.5">Min. {{ prod.stock_minimo }}</p>
              </td>

              <!-- P. Compra -->
              <td class="text-slate-400 font-mono">
                S/ {{ parseFloat(prod.precio_compra).toFixed(2) }}
              </td>

              <!-- P. Venta -->
              <td class="text-slate-100 font-mono font-semibold">
                S/ {{ parseFloat(prod.precio_venta).toFixed(2) }}
              </td>

              <!-- Estado -->
              <td>
                <span v-if="prod.estado" class="badge badge-emerald">
                  <span class="w-1.5 h-1.5 rounded-full bg-emerald-400 inline-block"></span>
                  Activo
                </span>
                <span v-else class="badge badge-slate">
                  <span class="w-1.5 h-1.5 rounded-full bg-slate-500 inline-block"></span>
                  Inactivo
                </span>
              </td>

              <!-- Acciones -->
              <td class="text-right">
                <div class="flex items-center justify-end gap-2">
                  <button @click="openModal(prod)" class="btn btn-secondary btn-sm" title="Editar">
                    <EditIcon class="w-3.5 h-3.5" />
                  </button>
                  <button @click="confirmDelete(prod)" class="btn btn-danger btn-sm" title="Eliminar">
                    <TrashIcon class="w-3.5 h-3.5" />
                  </button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Modal -->
    <div v-if="isModalOpen" class="modal-overlay">
      <div class="modal-box max-w-lg">
        <!-- Modal Header -->
        <div class="flex items-center justify-between mb-5">
          <h3 class="text-base font-semibold text-slate-100">
            {{ isEditMode ? 'Editar Producto' : 'Nuevo Producto' }}
          </h3>
          <button @click="closeModal" class="text-slate-500 hover:text-slate-300 transition">
            <span class="text-lg leading-none">&times;</span>
          </button>
        </div>

        <!-- Error -->
        <div v-if="errorMsg" class="mb-4 p-3 bg-red-500/10 border border-red-500/20 text-red-400 text-xs rounded-lg">
          {{ errorMsg }}
        </div>

        <form @submit.prevent="saveProducto" class="space-y-4">
          <!-- Código + Categoría -->
          <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div class="space-y-1.5">
              <label class="section-label">Código de Barras</label>
              <input
                type="text"
                v-model="form.codigo_barras"
                maxlength="50"
                placeholder="Escanea o escribe el código..."
                class="input w-full font-mono"
              />
            </div>
            <div class="space-y-1.5">
              <label class="section-label">Categoría</label>
              <select v-model="form.id_categoria" required class="input w-full">
                <option value="" disabled>Selecciona una categoría...</option>
                <option v-for="cat in categorias" :key="cat.id_categoria" :value="cat.id_categoria">
                  {{ cat.nombre }}
                </option>
              </select>
            </div>
          </div>

          <!-- Nombre -->
          <div class="space-y-1.5">
            <label class="section-label">Nombre del Producto</label>
            <input
              type="text"
              v-model="form.nombre"
              required
              maxlength="150"
              placeholder="Ej. Gaseosa Inka Kola 3L, Arroz Costeño 1kg..."
              class="input w-full"
            />
          </div>

          <!-- Descripción -->
          <div class="space-y-1.5">
            <label class="section-label">Descripción</label>
            <textarea
              v-model="form.descripcion"
              rows="2"
              placeholder="Detalles sobre presentación, sabor, empaque..."
              class="input w-full resize-none"
            ></textarea>
          </div>

          <!-- Precios -->
          <div class="grid grid-cols-2 gap-4">
            <div class="space-y-1.5">
              <label class="section-label">Precio Compra (S/)</label>
              <input
                type="number"
                step="0.01"
                min="0"
                v-model.number="form.precio_compra"
                required
                placeholder="0.00"
                class="input w-full font-mono"
              />
            </div>
            <div class="space-y-1.5">
              <label class="section-label">Precio Venta (S/)</label>
              <input
                type="number"
                step="0.01"
                min="0"
                v-model.number="form.precio_venta"
                required
                placeholder="0.00"
                class="input w-full font-mono"
              />
            </div>
          </div>

          <!-- Stock -->
          <div class="grid grid-cols-2 gap-4">
            <div class="space-y-1.5">
              <label class="section-label">Stock Inicial / Actual</label>
              <input
                type="number"
                min="0"
                v-model.number="form.stock_actual"
                :disabled="isEditMode"
                placeholder="0"
                class="input w-full font-mono disabled:opacity-40 disabled:cursor-not-allowed"
              />
              <span v-if="isEditMode" class="text-xs text-slate-500 block leading-tight">
                Para editar stock use Movimientos de Almacén
              </span>
            </div>
            <div class="space-y-1.5">
              <label class="section-label">Stock Mínimo</label>
              <input
                type="number"
                min="0"
                v-model.number="form.stock_minimo"
                required
                placeholder="5"
                class="input w-full font-mono"
              />
            </div>
          </div>

          <!-- Estado -->
          <div class="flex items-center gap-2.5 pt-1">
            <input
              type="checkbox"
              id="estado"
              v-model="form.estado"
              class="w-4 h-4 rounded border-slate-700 bg-slate-900 text-sky-600 focus:ring-sky-500/20 focus:ring-offset-0 focus:outline-none"
            />
            <label for="estado" class="text-sm text-slate-300 cursor-pointer">Producto habilitado para la venta</label>
          </div>

          <!-- Footer -->
          <div class="flex justify-end gap-3 pt-4 border-t border-slate-700">
            <button type="button" @click="closeModal" class="btn btn-secondary btn-sm">Cancelar</button>
            <button type="submit" :disabled="saving" class="btn btn-primary btn-sm disabled:opacity-50">
              <span v-if="saving">Guardando...</span>
              <span v-else>Guardar</span>
            </button>
          </div>
        </form>
      </div>
    </div>

  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue';
import { useRoute } from 'vue-router';
import axios from 'axios';
import api from '../services/api';
import { 
  Plus as PlusIcon, 
  Search as SearchIcon, 
  Inbox as InboxIcon, 
  Edit as EditIcon, 
  Trash2 as TrashIcon,
  AlertTriangle as AlertTriangleIcon,
  Barcode as BarcodeIcon
} from '@lucide/vue';

const route = useRoute();
const loading = ref(true);
const saving = ref(false);
const productos = ref([]);
const categorias = ref([]);
const searchQuery = ref('');
const selectedCategory = ref('');
const filterLowStock = ref(false);

// Watch for search query parameter from navbar
watch(() => route.query.q, (newVal) => {
  searchQuery.value = newVal || '';
}, { immediate: true });


// Modal y Formulario
const isModalOpen = ref(false);
const isEditMode = ref(false);
const errorMsg = ref('');
const form = ref({
  id_producto: null,
  codigo_barras: '',
  nombre: '',
  descripcion: '',
  stock_actual: 0,
  stock_minimo: 5,
  precio_compra: '',
  precio_venta: '',
  estado: true,
  id_categoria: ''
});

const loadProductos = async () => {
  loading.value = true;
  try {
  const response = await api.get('/productos');
    if (response.data.success) {
      productos.value = response.data.data;
    }
  } catch (err) {
    console.error('Error al cargar productos:', err);
  } finally {
    loading.value = false;
  }
};

const loadCategorias = async () => {
  try {
  const response = await api.get('/categorias');
    if (response.data.success) {
      categorias.value = response.data.data;
    }
  } catch (err) {
    console.error('Error al cargar categorías:', err);
  }
};

const toggleStockFilter = () => {
  filterLowStock.value = !filterLowStock.value;
};

const filteredProductos = computed(() => {
  let list = productos.value;

  // Filtrar por búsqueda de texto
  if (searchQuery.value.trim()) {
    const q = searchQuery.value.toLowerCase().trim();
    list = list.filter(prod => 
      prod.nombre.toLowerCase().includes(q) || 
      (prod.codigo_barras && prod.codigo_barras.toLowerCase().includes(q))
    );
  }

  // Filtrar por categoría
  if (selectedCategory.value) {
    list = list.filter(prod => prod.id_categoria == selectedCategory.value);
  }

  // Filtrar por stock bajo
  if (filterLowStock.value) {
    list = list.filter(prod => prod.stock_actual <= prod.stock_minimo);
  }

  return list;
});

const openModal = (prod = null) => {
  errorMsg.value = '';
  isModalOpen.value = true;
  if (prod) {
    isEditMode.value = true;
    form.value = { 
      ...prod,
      precio_compra: parseFloat(prod.precio_compra),
      precio_venta: parseFloat(prod.precio_venta)
    };
  } else {
    isEditMode.value = false;
    form.value = {
      id_producto: null,
      codigo_barras: '',
      nombre: '',
      descripcion: '',
      stock_actual: 0,
      stock_minimo: 5,
      precio_compra: '',
      precio_venta: '',
      estado: true,
      id_categoria: categorias.value[0]?.id_categoria || ''
    };
  }
};

const closeModal = () => {
  isModalOpen.value = false;
  errorMsg.value = '';
};

const saveProducto = async () => {
  saving.value = true;
  errorMsg.value = '';
  try {
    let response;
    if (isEditMode.value) {
      response = await api.put(`/productos/${form.value.id_producto}`, form.value);
    } else {
      response = await api.post('/productos', form.value);
    }
    
    if (response.data.success) {
      loadProductos();
      closeModal();
    }
  } catch (err) {
    console.error('Error al guardar producto:', err);
    errorMsg.value = err.response?.data?.message || 'Error al guardar el producto. Por favor revisa los datos.';
  } finally {
    saving.value = false;
  }
};

const confirmDelete = async (prod) => {
  const confirmed = confirm(`¿Estás seguro de que deseas eliminar el producto "${prod.nombre}"?`);
  if (!confirmed) return;

  try {
    const response = await api.delete(`/productos/${prod.id_producto}`);
    if (response.data.success) {
      alert(response.data.message);
      loadProductos();
    }
  } catch (err) {
    console.error('Error al eliminar producto:', err);
    alert(err.response?.data?.message || 'Error al eliminar el producto.');
  }
};

onMounted(() => {
  loadProductos();
  loadCategorias();
});
</script>
