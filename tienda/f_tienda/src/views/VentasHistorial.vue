<template>
  <div class="space-y-5 fade-in select-none">

    <!-- Header -->
    <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
      <div>
        <h1 class="text-lg font-semibold text-slate-100">Historial de Ventas</h1>
        <p class="text-xs text-slate-500 mt-0.5">Consulta comprobantes emitidos (Boletas y Facturas) y sus detalles</p>
      </div>
    </div>

    <!-- Filter Bar -->
    <div class="card p-4">
      <div class="flex flex-wrap gap-3 items-center justify-between">
        <!-- Search & Filter Group -->
        <div class="flex flex-1 flex-wrap gap-3 min-w-[280px]">
          <!-- Buscador -->
          <div class="relative flex-1 min-w-[200px]">
            <span class="absolute inset-y-0 left-3 flex items-center text-slate-500 pointer-events-none">
              <SearchIcon class="w-4 h-4" />
            </span>
            <input
              type="text"
              v-model="searchQuery"
              placeholder="Buscar comprobante o cliente..."
              class="input w-full pl-9"
            />
          </div>

          <!-- Filtro tipo comprobante -->
          <select
            v-model="selectedComprobanteType"
            class="input w-full sm:w-48"
          >
            <option value="">Todos los tipos</option>
            <option value="1">Boletas</option>
            <option value="2">Facturas</option>
          </select>
        </div>
      </div>
    </div>

    <!-- Tabla de Ventas -->
    <div class="card p-0 overflow-hidden">
      <!-- Loading -->
      <div v-if="loading" class="flex flex-col items-center justify-center py-20 gap-3">
        <span class="w-7 h-7 border-2 border-sky-500/30 border-t-sky-500 rounded-full animate-spin"></span>
        <p class="text-xs text-slate-500">Cargando historial...</p>
      </div>

      <!-- Empty -->
      <div v-else-if="filteredVentas.length === 0" class="flex flex-col items-center justify-center py-20 gap-3">
        <InboxIcon class="w-10 h-10 text-slate-700" />
        <p class="text-xs text-slate-500">No se encontraron ventas</p>
      </div>

      <!-- Table -->
      <div v-else class="table-wrap">
        <table class="data-table">
          <thead>
            <tr>
              <th>Comprobante</th>
              <th>Fecha / Hora</th>
              <th>Cliente</th>
              <th>Cajero</th>
              <th>Subtotal</th>
              <th>IGV</th>
              <th class="text-right">Total</th>
              <th class="text-right">Acción</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="venta in filteredVentas" :key="venta.id_venta">
              <!-- Comprobante -->
              <td>
                <div class="flex flex-col gap-1">
                  <span class="font-mono font-semibold text-slate-100 text-xs">{{ venta.numero_comprobante }}</span>
                  <span
                    :class="[
                      venta.id_tipo_comprobante === 2 ? 'badge badge-sky' : 'badge badge-slate'
                    ]"
                  >
                    {{ venta.tipo_comprobante?.nombre || 'Comprobante' }}
                  </span>
                </div>
              </td>

              <!-- Fecha -->
              <td class="font-mono text-slate-400 whitespace-nowrap">{{ formatDate(venta.fecha_venta) }}</td>

              <!-- Cliente -->
              <td>
                <div class="flex flex-col">
                  <span class="text-slate-100 font-medium">{{ venta.cliente?.nombres || 'Cliente Varios' }}</span>
                  <span v-if="venta.cliente?.dni_ruc" class="text-xs text-slate-500 font-mono">
                    {{ venta.cliente.dni_ruc }}
                  </span>
                </div>
              </td>

              <!-- Cajero -->
              <td class="text-slate-400">{{ venta.usuario?.nombres || 'Cajero' }}</td>

              <!-- Subtotal -->
              <td class="font-mono text-slate-400">S/ {{ parseFloat(venta.subtotal ?? 0).toFixed(2) }}</td>

              <!-- IGV -->
              <td class="font-mono text-slate-400">S/ {{ parseFloat(venta.igv ?? 0).toFixed(2) }}</td>

              <!-- Total -->
              <td class="text-right font-mono font-bold text-sky-400">
                S/ {{ parseFloat(venta.total).toFixed(2) }}
              </td>

              <!-- Acción -->
              <td class="text-right">
                <button
                  @click="viewDetails(venta.id_venta)"
                  class="btn btn-secondary btn-sm inline-flex items-center gap-1.5"
                >
                  <EyeIcon class="w-3.5 h-3.5" />
                  Ver Ticket
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Modal Detalle Comprobante -->
    <div v-if="isDetailModalOpen" class="modal-overlay" @click.self="closeDetailModal">
      <div class="modal-box max-w-sm w-full">

        <!-- Loading detalles -->
        <div v-if="loadingDetails" class="flex flex-col items-center justify-center py-16 gap-3">
          <span class="w-7 h-7 border-2 border-sky-500/30 border-t-sky-500 rounded-full animate-spin"></span>
          <p class="text-xs text-slate-500">Cargando comprobante...</p>
        </div>

        <div v-else>
          <!-- Modal Header -->
          <div class="flex items-center justify-between mb-5">
            <div>
              <h3 class="text-sm font-semibold text-slate-100">Detalle del Comprobante</h3>
              <p class="text-xs text-slate-500 mt-0.5 font-mono">{{ selectedVenta.numero_comprobante }}</p>
            </div>
            <span
              :class="[
                selectedVenta.id_tipo_comprobante === 2 ? 'badge badge-sky' : 'badge badge-slate'
              ]"
            >
              {{ selectedVenta.tipo_comprobante?.nombre || 'Comprobante' }}
            </span>
          </div>

          <!-- Info de la venta -->
          <div class="space-y-1.5 text-xs mb-5 p-3 bg-slate-900 rounded-lg border border-slate-700">
            <div class="flex justify-between">
              <span class="text-slate-500">Fecha</span>
              <span class="font-mono text-slate-300">{{ formatDate(selectedVenta.fecha_venta) }}</span>
            </div>
            <div class="flex justify-between">
              <span class="text-slate-500">Cliente</span>
              <span class="text-slate-100 font-medium truncate max-w-[180px]">{{ selectedVenta.cliente?.nombres || 'Cliente Varios' }}</span>
            </div>
            <div v-if="selectedVenta.cliente?.dni_ruc" class="flex justify-between">
              <span class="text-slate-500">DNI / RUC</span>
              <span class="font-mono text-slate-300">{{ selectedVenta.cliente?.dni_ruc }}</span>
            </div>
            <div class="flex justify-between">
              <span class="text-slate-500">Cajero</span>
              <span class="text-slate-300">{{ selectedVenta.usuario?.nombres }}</span>
            </div>
          </div>

          <!-- Tabla de items -->
          <div class="mb-5">
            <p class="section-label mb-2">Detalle de productos</p>
            <div class="table-wrap rounded-lg border border-slate-700">
              <table class="data-table text-xs">
                <thead>
                  <tr>
                    <th>Producto</th>
                    <th class="text-center">Cant.</th>
                    <th class="text-right">Subtotal</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="det in selectedVenta.detalles" :key="det.id_detalle">
                    <td class="text-slate-200">{{ det.producto?.nombre }}</td>
                    <td class="text-center font-mono">{{ det.cantidad }}</td>
                    <td class="text-right font-mono text-slate-300">S/ {{ parseFloat(det.subtotal).toFixed(2) }}</td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>

          <!-- Totales -->
          <div class="space-y-1.5 text-xs border-t border-slate-700 pt-4 mb-5">
            <div class="flex justify-between text-slate-400">
              <span>Subtotal</span>
              <span class="font-mono">S/ {{ parseFloat(selectedVenta.subtotal).toFixed(2) }}</span>
            </div>
            <div v-if="parseFloat(selectedVenta.igv) > 0" class="flex justify-between text-slate-400">
              <span>IGV (18%)</span>
              <span class="font-mono">S/ {{ parseFloat(selectedVenta.igv).toFixed(2) }}</span>
            </div>
            <div class="flex justify-between font-bold text-sm pt-1.5 border-t border-slate-700">
              <span class="text-slate-100">Total Cancelado</span>
              <span class="font-mono text-sky-400">S/ {{ parseFloat(selectedVenta.total).toFixed(2) }}</span>
            </div>
          </div>

          <!-- Footer acciones -->
          <div class="flex gap-2">
            <button @click="closeDetailModal" class="btn btn-secondary flex-1">
              Cerrar
            </button>
            <button @click="printTicket" class="btn btn-primary flex-1 inline-flex items-center justify-center gap-1.5">
              <PrinterIcon class="w-3.5 h-3.5" />
              Imprimir
            </button>
          </div>
        </div>
      </div>
    </div>

  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import axios from 'axios';
import { 
  Search as SearchIcon, 
  Inbox as InboxIcon, 
  Eye as EyeIcon, 
  Printer as PrinterIcon
} from '@lucide/vue';

const loading = ref(true);
const ventas = ref([]);
const searchQuery = ref('');
const selectedComprobanteType = ref('');

// Modal de detalle
const isDetailModalOpen = ref(false);
const loadingDetails = ref(false);
const selectedVenta = ref({});

const loadVentas = async () => {
  loading.value = true;
  try {
    const response = await axios.get('/ventas');
    if (response.data.success) {
      ventas.value = response.data.data;
    }
  } catch (err) {
    console.error('Error al cargar ventas:', err);
  } finally {
    loading.value = false;
  }
};

const filteredVentas = computed(() => {
  let list = ventas.value;

  if (searchQuery.value.trim()) {
    const q = searchQuery.value.toLowerCase().trim();
    list = list.filter(v => 
      v.numero_comprobante.toLowerCase().includes(q) ||
      (v.cliente?.nombres && v.cliente.nombres.toLowerCase().includes(q))
    );
  }

  if (selectedComprobanteType.value) {
    list = list.filter(v => v.id_tipo_comprobante == selectedComprobanteType.value);
  }

  return list;
});

const viewDetails = async (id) => {
  isDetailModalOpen.value = true;
  loadingDetails.value = true;
  try {
    const response = await axios.get(`/ventas/${id}`);
    if (response.data.success) {
      selectedVenta.value = response.data.data;
    }
  } catch (err) {
    console.error('Error al cargar detalles de la venta:', err);
    alert('No se pudieron obtener los detalles del comprobante.');
    closeDetailModal();
  } finally {
    loadingDetails.value = false;
  }
};

const closeDetailModal = () => {
  isDetailModalOpen.value = false;
  selectedVenta.value = {};
};

const printTicket = () => {
  window.print();
};

const formatDate = (dateStr) => {
  if (!dateStr) return '';
  const d = new Date(dateStr);
  return d.toLocaleString('es-PE', { timeZone: 'America/Lima' });
};

onMounted(() => {
  loadVentas();
});
</script>

<style scoped>
/* Print CSS */
@media print {
  body * {
    visibility: hidden;
  }
  .modal-overlay {
    position: absolute;
    left: 0;
    top: 0;
    width: 100%;
    height: auto;
    background: white !important;
    visibility: visible;
  }
  .modal-box {
    visibility: visible;
    border: none !important;
    box-shadow: none !important;
    margin: 0;
    width: 100%;
    max-width: 100%;
    background: white !important;
    color: black !important;
  }
  .modal-box * {
    visibility: visible;
    color: black !important;
  }
  .modal-box .flex.gap-2:last-child {
    display: none !important;
  }
}
</style>
