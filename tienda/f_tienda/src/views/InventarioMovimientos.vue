<template>
  <div class="space-y-5 fade-in select-none">

    <!-- Header -->
    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
      <div>
        <h1 class="text-lg font-semibold text-slate-100">Movimientos de Inventario</h1>
        <p class="text-xs text-slate-500 mt-0.5">Controla entradas, salidas y ajustes manuales del stock físico</p>
      </div>
      <button
        @click="openModal()"
        class="btn btn-primary w-full sm:w-auto inline-flex items-center justify-center gap-2"
      >
        <PlusIcon class="w-4 h-4" />
        Registrar Movimiento
      </button>
    </div>

    <!-- Filtros -->
    <div class="card p-4 grid grid-cols-1 sm:grid-cols-3 gap-3">
      <!-- Producto -->
      <div class="space-y-1.5">
        <label class="section-label">Filtrar por Producto</label>
        <select
          v-model="filters.id_producto"
          @change="loadMovimientos"
          class="input w-full"
        >
          <option value="">Todos los productos</option>
          <option v-for="prod in productos" :key="prod.id_producto" :value="prod.id_producto">
            {{ prod.nombre }}
          </option>
        </select>
      </div>

      <!-- Tipo de Movimiento -->
      <div class="space-y-1.5">
        <label class="section-label">Tipo de Movimiento</label>
        <select
          v-model="filters.tipo_movimiento"
          @change="loadMovimientos"
          class="input w-full"
        >
          <option value="">Todos los tipos</option>
          <option value="ENTRADA">ENTRADA (Ingreso)</option>
          <option value="SALIDA">SALIDA (Egreso)</option>
        </select>
      </div>

      <!-- Motivo -->
      <div class="space-y-1.5">
        <label class="section-label">Motivo del Ajuste</label>
        <select
          v-model="filters.id_motivo"
          @change="loadMovimientos"
          class="input w-full"
        >
          <option value="">Todos los motivos</option>
          <option v-for="mot in motivos" :key="mot.id_motivo" :value="mot.id_motivo">
            {{ mot.nombre }}
          </option>
        </select>
      </div>
    </div>

    <!-- Historial de Movimientos -->
    <div class="card p-0 overflow-hidden">

      <!-- Loading -->
      <div v-if="loading" class="flex flex-col items-center justify-center py-20 gap-3">
        <span class="w-7 h-7 border-2 border-sky-500/30 border-t-sky-500 rounded-full animate-spin"></span>
        <p class="text-xs text-slate-500">Cargando movimientos...</p>
      </div>

      <!-- Empty -->
      <div v-else-if="movimientos.length === 0" class="flex flex-col items-center justify-center py-20 gap-3">
        <InboxIcon class="w-10 h-10 text-slate-700" />
        <p class="text-xs text-slate-500">No hay movimientos con los filtros aplicados</p>
      </div>

      <!-- Table -->
      <div v-else class="table-wrap">
        <table class="data-table">
          <thead>
            <tr>
              <th>Fecha / Hora</th>
              <th>Producto</th>
              <th>Tipo</th>
              <th>Motivo</th>
              <th class="text-center">Cantidad</th>
              <th>Variación Stock</th>
              <th>Operador</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="mov in movimientos" :key="mov.id_movimiento">

              <!-- Fecha -->
              <td class="font-mono text-slate-400 whitespace-nowrap text-xs">
                {{ formatDate(mov.fecha_movimiento) }}
              </td>

              <!-- Producto -->
              <td class="font-medium text-slate-100">{{ mov.producto?.nombre }}</td>

              <!-- Tipo -->
              <td>
                <span
                  :class="[
                    'badge',
                    mov.tipo_movimiento === 'ENTRADA' ? 'badge-emerald' : 'badge-red'
                  ]"
                >
                  {{ mov.tipo_movimiento }}
                </span>
              </td>

              <!-- Motivo -->
              <td class="text-slate-400">{{ mov.motivo?.nombre }}</td>

              <!-- Cantidad -->
              <td class="text-center font-mono font-bold text-slate-100">
                {{ mov.cantidad }} <span class="text-slate-500 font-normal">uds</span>
              </td>

              <!-- Variación Stock -->
              <td class="font-mono text-slate-400">
                <span class="text-slate-300">{{ mov.stock_anterior }}</span>
                <span class="text-slate-600 mx-1">→</span>
                <span :class="mov.tipo_movimiento === 'ENTRADA' ? 'text-emerald-400' : 'text-red-400'">
                  {{ mov.stock_nuevo }}
                </span>
              </td>

              <!-- Operador -->
              <td class="text-slate-400">{{ mov.usuario?.nombres }}</td>

            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Modal Registrar Movimiento -->
    <div
      v-if="isModalOpen"
      class="modal-overlay"
      @click.self="closeModal"
    >
      <div class="modal-box max-w-md w-full">

        <!-- Modal Header -->
        <div class="flex items-center justify-between mb-5">
          <div>
            <h3 class="text-sm font-semibold text-slate-100">Registrar Movimiento</h3>
            <p class="text-xs text-slate-500 mt-0.5">Ajuste manual de entrada o salida de stock</p>
          </div>
          <button @click="closeModal" class="text-slate-500 hover:text-slate-300 transition">
            <svg xmlns="http://www.w3.org/2000/svg" class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
          </button>
        </div>

        <!-- Error -->
        <div v-if="errorMsg" class="mb-4 p-3 rounded-lg border border-red-500/30 bg-red-500/10 text-red-400 text-xs">
          {{ errorMsg }}
        </div>

        <form @submit.prevent="saveMovimiento" class="space-y-4">

          <!-- Producto -->
          <div class="space-y-1.5">
            <label class="section-label">Producto</label>
            <select v-model="form.id_producto" required class="input w-full">
              <option value="" disabled>Selecciona el producto...</option>
              <option v-for="prod in productos" :key="prod.id_producto" :value="prod.id_producto">
                {{ prod.nombre }} (Stock: {{ prod.stock_actual }})
              </option>
            </select>
          </div>

          <div class="grid grid-cols-2 gap-3">
            <!-- Tipo Operación -->
            <div class="space-y-1.5">
              <label class="section-label">Tipo Operación</label>
              <select v-model="form.tipo_movimiento" required class="input w-full">
                <option value="ENTRADA">ENTRADA (+)</option>
                <option value="SALIDA">SALIDA (-)</option>
              </select>
            </div>

            <!-- Motivo -->
            <div class="space-y-1.5">
              <label class="section-label">Motivo</label>
              <select v-model="form.id_motivo" required class="input w-full">
                <option value="" disabled>Motivo...</option>
                <option v-for="mot in filteredMotivos" :key="mot.id_motivo" :value="mot.id_motivo">
                  {{ mot.nombre }}
                </option>
              </select>
            </div>
          </div>

          <!-- Cantidad -->
          <div class="space-y-1.5">
            <label class="section-label">Cantidad (Unidades)</label>
            <input
              type="number"
              min="1"
              v-model.number="form.cantidad"
              required
              placeholder="Ej. 10"
              class="input w-full font-mono"
            />
          </div>

          <!-- Observaciones -->
          <div class="space-y-1.5">
            <label class="section-label">Observaciones <span class="normal-case text-slate-600">(opcional)</span></label>
            <textarea
              v-model="form.observaciones"
              rows="3"
              placeholder="Número de lote, guía de compra, detalle del ajuste..."
              class="input w-full resize-none"
            ></textarea>
          </div>

          <!-- Tipo visual indicator -->
          <div
            :class="[
              'flex items-center gap-2 px-3 py-2 rounded-lg text-xs font-medium border',
              form.tipo_movimiento === 'ENTRADA'
                ? 'bg-emerald-500/10 border-emerald-500/20 text-emerald-400'
                : 'bg-red-500/10 border-red-500/20 text-red-400'
            ]"
          >
            <span v-if="form.tipo_movimiento === 'ENTRADA'">↑ Este movimiento incrementará el stock disponible</span>
            <span v-else>↓ Este movimiento reducirá el stock disponible</span>
          </div>

          <!-- Acciones -->
          <div class="flex gap-2 pt-2 border-t border-slate-700">
            <button
              type="button"
              @click="closeModal"
              class="btn btn-secondary flex-1"
            >
              Cancelar
            </button>
            <button
              type="submit"
              :disabled="saving"
              class="btn btn-primary flex-1 disabled:opacity-50"
            >
              <span v-if="saving">Procesando...</span>
              <span v-else>Aplicar Cambio</span>
            </button>
          </div>
        </form>
      </div>
    </div>

  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import axios from 'axios';
import api from '../services/api';
import { 
  Plus as PlusIcon, 
  Search as SearchIcon, 
  Inbox as InboxIcon
} from '@lucide/vue';

const loading = ref(true);
const saving = ref(false);
const movimientos = ref([]);
const productos = ref([]);
const motivos = ref([]);

// Filtros de búsqueda
const filters = ref({
  id_producto: '',
  tipo_movimiento: '',
  id_motivo: ''
});

// Modal y Formulario
const isModalOpen = ref(false);
const errorMsg = ref('');
const form = ref({
  id_producto: '',
  tipo_movimiento: 'ENTRADA',
  id_motivo: '',
  cantidad: '',
  observaciones: ''
});

const loadMovimientos = async () => {
  loading.value = true;
  try {
    // Construir query params
    const params = {};
    if (filters.value.id_producto) params.id_producto = filters.value.id_producto;
    if (filters.value.tipo_movimiento) params.tipo_movimiento = filters.value.tipo_movimiento;
    if (filters.value.id_motivo) params.id_motivo = filters.value.id_motivo;

    const response = await api.get('/inventario/movimientos', { params });
    if (response.data.success) {
      movimientos.value = response.data.data;
    }
  } catch (err) {
    console.error('Error al cargar movimientos:', err);
  } finally {
    loading.value = false;
  }
};

const loadProductos = async () => {
  try {
    const response = await api.get('/productos');
    if (response.data.success) {
      productos.value = response.data.data;
    }
  } catch (err) {
    console.error('Error al cargar productos:', err);
  }
};

const loadMotivos = async () => {
  try {
    const response = await api.get('/motivos-movimiento');
    if (response.data.success) {
      motivos.value = response.data.data;
    }
  } catch (err) {
    console.error('Error al cargar motivos:', err);
  }
};

// Filtrar motivos del select según el tipo de movimiento seleccionado en el formulario
const filteredMotivos = computed(() => {
  if (form.value.tipo_movimiento === 'ENTRADA') {
    // ENTRADA: Compra (1) o Ajuste (3)
    return motivos.value.filter(m => m.id_motivo === 1 || m.id_motivo === 3);
  } else {
    // SALIDA: Venta (2), Ajuste (3) o Producto roto (4)
    // El motivo "Venta" (2) generalmente es automático desde el POS, pero lo listamos por si acaso
    return motivos.value.filter(m => m.id_motivo === 2 || m.id_motivo === 3 || m.id_motivo === 4);
  }
});

const openModal = () => {
  errorMsg.value = '';
  form.value = {
    id_producto: productos.value[0]?.id_producto || '',
    tipo_movimiento: 'ENTRADA',
    id_motivo: 1, // Compra por defecto
    cantidad: '',
    observaciones: ''
  };
  isModalOpen.value = true;
};

const closeModal = () => {
  isModalOpen.value = false;
  errorMsg.value = '';
};

const saveMovimiento = async () => {
  saving.value = true;
  errorMsg.value = '';
  try {
    const response = await api.post('/inventario/movimientos', form.value);
    if (response.data.success) {
      await loadMovimientos();
      await loadProductos(); // Recargar stock disponible de los productos
      closeModal();
    }
  } catch (err) {
    console.error('Error al registrar movimiento:', err);
    errorMsg.value = err.response?.data?.error || err.response?.data?.message || 'Error al procesar el ajuste de inventario.';
  } finally {
    saving.value = false;
  }
};

const formatDate = (dateStr) => {
  if (!dateStr) return '';
  const d = new Date(dateStr);
  return d.toLocaleString('es-PE', { timeZone: 'America/Lima' });
};

onMounted(() => {
  loadMovimientos();
  loadProductos();
  loadMotivos();
});
</script>
