<template>
  <div class="fade-in flex flex-col lg:flex-row gap-4 h-full">

    <!-- ── LEFT: Catálogo ───────────────────────────────── -->
    <div class="flex flex-col gap-3 lg:flex-1 min-h-0">

      <!-- Search & filter -->
      <div class="flex flex-wrap gap-2">
        <div class="relative flex-1 min-w-[200px]">
          <SearchIcon class="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-500" />
          <input type="text" v-model="searchQuery" placeholder="Buscar producto o código..."
            class="input pl-9 text-sm w-full" />
        </div>
        <select v-model="selectedCategory" class="input w-full sm:w-44 text-sm">
          <option value="">Todas las categorías</option>
          <option v-for="cat in categorias" :key="cat.id_categoria" :value="cat.id_categoria">{{ cat.nombre }}</option>
        </select>
      </div>

      <!-- Product grid -->
      <div class="flex-1 overflow-y-auto min-h-[300px] lg:min-h-0">
        <div v-if="loadingProds" class="flex items-center justify-center py-20">
          <span class="w-7 h-7 border-2 border-sky-500/30 border-t-sky-500 rounded-full animate-spin"></span>
        </div>
        <div v-else-if="!filteredProductos.length" class="flex flex-col items-center py-20 text-slate-600">
          <InboxIcon class="w-8 h-8 mb-2" /><p class="text-xs">Sin productos disponibles</p>
        </div>
        <div v-else class="grid grid-cols-2 sm:grid-cols-3 xl:grid-cols-4 gap-2.5">
          <button
            v-for="prod in filteredProductos" :key="prod.id_producto"
            @click="addToCart(prod)" :disabled="prod.stock_actual === 0"
            :class="['card p-3 text-left transition-all flex flex-col gap-2',
              prod.stock_actual === 0 ? 'opacity-40 cursor-not-allowed' : 'hover:border-sky-600/50 hover:bg-slate-700/50 active:scale-95']"
          >
            <div class="flex items-center justify-between gap-1">
              <span class="badge badge-sky text-[9px] truncate max-w-[70%]">{{ prod.categoria?.nombre || 'General' }}</span>
              <span :class="['text-[9px] font-mono font-bold',
                prod.stock_actual === 0 ? 'text-red-400' :
                prod.stock_actual <= prod.stock_minimo ? 'text-amber-400' : 'text-emerald-400']">
                {{ prod.stock_actual }}u
              </span>
            </div>
            <div>
              <p class="text-xs font-semibold text-slate-100 leading-tight line-clamp-2">{{ prod.nombre }}</p>
              <p class="text-[10px] text-slate-500 font-mono mt-0.5">{{ prod.codigo_barras || '—' }}</p>
            </div>
            <div class="mt-auto pt-2 border-t border-slate-700 flex items-center justify-between">
              <span class="text-sm font-bold text-slate-100">S/ {{ parseFloat(prod.precio_venta).toFixed(2) }}</span>
              <span class="text-[10px] text-sky-400 flex items-center gap-0.5">
                <PlusIcon class="w-3 h-3" /> Agregar
              </span>
            </div>
          </button>
        </div>
      </div>
    </div>

    <!-- ── RIGHT: Carrito + Formulario ─────────────────── -->
    <div class="card flex flex-col lg:w-80 xl:w-96 shrink-0 min-h-[500px] lg:min-h-0 overflow-hidden">

      <!-- Cart header -->
      <div class="px-4 py-3 border-b border-slate-700 flex items-center justify-between">
        <h3 class="text-sm font-semibold text-slate-100 flex items-center gap-2">
          <CartIcon class="w-4 h-4 text-sky-400" /> Venta
        </h3>
        <button v-if="cart.length" @click="clearCart" class="text-xs text-slate-500 hover:text-red-400 transition-colors">
          Limpiar
        </button>
      </div>

      <!-- Cart items -->
      <div class="flex-1 overflow-y-auto px-4 py-3 space-y-2 min-h-[120px]">
        <div v-if="!cart.length" class="flex flex-col items-center justify-center h-24 text-slate-600">
          <CartIcon class="w-7 h-7 mb-1.5" />
          <p class="text-xs">Agrega productos al carrito</p>
        </div>
        <div v-for="item in cart" :key="item.id_producto"
          class="flex items-start gap-3 py-2 border-b border-slate-800 last:border-0">
          <div class="flex-1 min-w-0">
            <p class="text-xs font-medium text-slate-200 leading-tight truncate">{{ item.nombre }}</p>
            <p class="text-[10px] text-slate-500 mt-0.5">S/ {{ parseFloat(item.precio_venta).toFixed(2) }} c/u</p>
          </div>
          <div class="flex items-center gap-1.5 shrink-0">
            <button @click="decreaseQty(item)"
              class="w-6 h-6 rounded bg-slate-700 hover:bg-slate-600 text-slate-300 flex items-center justify-center text-sm font-bold transition-colors">−</button>
            <span class="text-xs font-bold text-slate-100 w-5 text-center">{{ item.qty }}</span>
            <button @click="increaseQty(item)"
              class="w-6 h-6 rounded bg-slate-700 hover:bg-slate-600 text-slate-300 flex items-center justify-center text-sm font-bold transition-colors">+</button>
            <button @click="removeFromCart(item)" class="w-6 h-6 rounded hover:bg-red-900/30 text-slate-600 hover:text-red-400 flex items-center justify-center transition-colors ml-1">
              <TrashIcon class="w-3 h-3" />
            </button>
          </div>
          <div class="text-xs font-semibold text-slate-100 shrink-0 text-right w-14">
            S/ {{ (item.precio_venta * item.qty).toFixed(2) }}
          </div>
        </div>
      </div>

      <!-- Formulario + Totales -->
      <div class="border-t border-slate-700 px-4 py-4 space-y-3 bg-slate-900/50">

        <!-- Cliente -->
        <div class="space-y-1.5">
          <div class="flex items-center justify-between">
            <label class="section-label">Cliente</label>
            <button @click="openNewClientModal" class="text-[10px] text-sky-400 hover:text-sky-300 transition-colors">+ Nuevo</button>
          </div>
          <select v-model="form.id_cliente" class="input text-sm">
            <option value="" disabled>Seleccionar cliente...</option>
            <option v-for="cli in clientes" :key="cli.id_cliente" :value="cli.id_cliente">
              {{ cli.nombres }}
            </option>
          </select>
        </div>

        <!-- Comprobante -->
        <div class="space-y-1.5">
          <label class="section-label">Comprobante</label>
          <div class="grid grid-cols-2 gap-2">
            <button @click="form.id_tipo_comprobante = 1"
              :class="['py-2 rounded-lg text-xs font-semibold border transition-colors',
                form.id_tipo_comprobante === 1
                  ? 'bg-sky-600 border-sky-600 text-white'
                  : 'bg-slate-800 border-slate-700 text-slate-400 hover:border-slate-600']">
              Boleta
            </button>
            <button @click="form.id_tipo_comprobante = 2"
              :class="['py-2 rounded-lg text-xs font-semibold border transition-colors',
                form.id_tipo_comprobante === 2
                  ? 'bg-sky-600 border-sky-600 text-white'
                  : 'bg-slate-800 border-slate-700 text-slate-400 hover:border-slate-600']">
              Factura
            </button>
          </div>
        </div>

        <!-- Totales -->
        <div class="space-y-1 pt-2 border-t border-slate-700/50">
          <div v-if="form.id_tipo_comprobante === 2" class="flex justify-between text-xs">
            <span class="text-slate-500">Subtotal</span>
            <span class="text-slate-300">S/ {{ calculatedSubtotal.toFixed(2) }}</span>
          </div>
          <div v-if="form.id_tipo_comprobante === 2" class="flex justify-between text-xs">
            <span class="text-slate-500">IGV (18%)</span>
            <span class="text-slate-300">S/ {{ calculatedIgv.toFixed(2) }}</span>
          </div>
          <div class="flex justify-between items-center">
            <span class="text-sm font-semibold text-slate-400">Total</span>
            <span class="text-xl font-bold text-slate-100">S/ {{ calculatedTotal.toFixed(2) }}</span>
          </div>
        </div>

        <!-- Confirm -->
        <Button @click="submitVenta" :disabled="!cart.length || !form.id_cliente || submitting" variant="primary" class="w-full">
          <span v-if="submitting" class="w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin"></span>
          <template v-else>Confirmar venta</template>
        </Button>
      </div>
    </div>

    <!-- ── Modal Nuevo Cliente ──────────────────────────── -->
    <div v-if="isNewClientModalOpen" class="modal-overlay">
      <div class="modal-box">
        <h3 class="text-sm font-semibold text-slate-100 mb-4">Registrar cliente rápido</h3>
        <div v-if="clientErrorMsg" class="mb-3 p-3 bg-red-950/40 border border-red-800/50 rounded-lg text-xs text-red-400">{{ clientErrorMsg }}</div>
        <form @submit.prevent="saveQuickClient" class="space-y-3">
          <div><label class="block text-xs font-medium text-slate-400 mb-1">Nombre *</label>
            <input type="text" v-model="newClientForm.nombres" required class="input" placeholder="Juan Pérez" /></div>
          <div class="grid grid-cols-2 gap-3">
            <div><label class="block text-xs font-medium text-slate-400 mb-1">DNI/RUC</label>
              <input type="text" v-model="newClientForm.dni_ruc" class="input font-mono" placeholder="45678912" /></div>
            <div><label class="block text-xs font-medium text-slate-400 mb-1">Teléfono</label>
              <input type="text" v-model="newClientForm.telefono" class="input font-mono" placeholder="987654321" /></div>
          </div>
          <div><label class="block text-xs font-medium text-slate-400 mb-1">Dirección</label>
            <input type="text" v-model="newClientForm.direccion" class="input" placeholder="Av. Ejemplo 123" /></div>
          <div class="flex justify-end gap-2 pt-3 border-t border-slate-700">
            <button type="button" @click="closeNewClientModal" class="btn btn-secondary btn-sm">Cancelar</button>
            <Button type="submit" :disabled="savingClient" variant="primary" class="btn-sm">
              {{ savingClient ? 'Guardando...' : 'Guardar cliente' }}
            </Button>
          </div>
        </form>
      </div>
    </div>

    <!-- ── Modal Éxito / Ticket ────────────────────────── -->
    <div v-if="isSuccessModalOpen" class="modal-overlay">
      <div class="modal-box max-w-sm" id="ticket-print">
        <!-- Ticket header -->
        <div class="text-center mb-4">
          <div class="w-12 h-12 bg-emerald-500/10 rounded-full flex items-center justify-center mx-auto mb-3">
            <svg class="w-6 h-6 text-emerald-400" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" d="m4.5 12.75 6 6 9-13.5" />
            </svg>
          </div>
          <h3 class="text-base font-bold text-slate-100">Venta registrada</h3>
          <p class="text-sm font-mono text-sky-400 mt-1">{{ successVentaData.numero_comprobante }}</p>
          <p class="text-xs text-slate-500 mt-0.5">{{ formatDate(successVentaData.fecha_venta) }}</p>
        </div>

        <!-- Cliente + cajero -->
        <div class="space-y-1 text-xs mb-4 p-3 bg-slate-900 rounded-lg">
          <div class="flex justify-between"><span class="text-slate-500">Cliente</span><span class="text-slate-300">{{ successVentaData.cliente?.nombres }}</span></div>
          <div class="flex justify-between"><span class="text-slate-500">Cajero</span><span class="text-slate-300">{{ successVentaData.usuario?.nombres }}</span></div>
          <div class="flex justify-between"><span class="text-slate-500">Comprobante</span><span class="text-slate-300">{{ successVentaData.tipo_comprobante?.nombre }}</span></div>
        </div>

        <!-- Items -->
        <div class="space-y-1 text-xs mb-4">
          <div v-for="det in successVentaData.detalles" :key="det.id_detalle"
            class="flex justify-between text-slate-400">
            <span class="flex-1 truncate">{{ det.producto?.nombre }}</span>
            <span class="shrink-0 ml-2">{{ det.cantidad }} × S/ {{ parseFloat(det.precio_unitario).toFixed(2) }}</span>
            <span class="shrink-0 ml-3 text-slate-200 w-14 text-right">S/ {{ parseFloat(det.subtotal).toFixed(2) }}</span>
          </div>
        </div>

        <!-- Totales -->
        <div class="border-t border-slate-700 pt-3 space-y-1 text-xs">
          <div v-if="successVentaData.igv > 0" class="flex justify-between text-slate-400">
            <span>Subtotal</span><span>S/ {{ parseFloat(successVentaData.subtotal).toFixed(2) }}</span>
          </div>
          <div v-if="successVentaData.igv > 0" class="flex justify-between text-slate-400">
            <span>IGV (18%)</span><span>S/ {{ parseFloat(successVentaData.igv).toFixed(2) }}</span>
          </div>
          <div class="flex justify-between font-bold text-slate-100 text-sm pt-1">
            <span>TOTAL</span><span>S/ {{ parseFloat(successVentaData.total).toFixed(2) }}</span>
          </div>
        </div>

        <!-- Buttons -->
        <div class="flex gap-2 mt-5">
          <button @click="printTicket" class="btn btn-secondary btn-sm flex-1">
            <PrinterIcon class="w-3.5 h-3.5" /> Imprimir
          </button>
          <button @click="closeSuccessModal" class="btn btn-primary btn-sm flex-1">
            Nueva venta
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import axios from 'axios';
import api from '../services/api';
import {
  Search as SearchIcon, Inbox as InboxIcon, Plus as PlusIcon,
  ShoppingCart as CartIcon, Trash2 as TrashIcon, Printer as PrinterIcon
} from '@lucide/vue';

const prods = ref([]);
const categorias = ref([]);
const clientes = ref([]);
const loadingProds = ref(true);
const searchQuery = ref('');
const selectedCategory = ref('');
const submitting = ref(false);

const cart = ref([]);
const form = ref({ id_cliente: '', id_tipo_comprobante: 1, items: [] });

const isNewClientModalOpen = ref(false);
const savingClient = ref(false);
const clientErrorMsg = ref('');
const newClientForm = ref({ nombres: '', dni_ruc: '', direccion: '', telefono: '' });

const isSuccessModalOpen = ref(false);
const successVentaData = ref({});

const loadProductos = async () => {
  loadingProds.value = true;
  try { const r = await api.get('/productos'); if (r.data.success) prods.value = r.data.data.filter(p => p.estado); }
  catch (e) { console.error(e); } finally { loadingProds.value = false; }
};
const loadCategorias = async () => {
  try { const r = await api.get('/categorias'); if (r.data.success) categorias.value = r.data.data; }
  catch (e) { console.error(e); }
};
const loadClientes = async (selectId = null) => {
  try {
    const r = await api.get('/clientes');
    if (r.data.success) {
      clientes.value = r.data.data;
      if (selectId) { form.value.id_cliente = selectId; }
      else if (clientes.value.length > 0 && !form.value.id_cliente) {
        const pub = clientes.value.find(c => c.nombres.toLowerCase().includes('general') || c.nombres.toLowerCase().includes('público') || c.nombres.toLowerCase().includes('varios'));
        form.value.id_cliente = pub ? pub.id_cliente : clientes.value[0].id_cliente;
      }
    }
  } catch (e) { console.error(e); }
};

const filteredProductos = computed(() => {
  let list = prods.value;
  if (searchQuery.value.trim()) { const q = searchQuery.value.toLowerCase(); list = list.filter(p => p.nombre.toLowerCase().includes(q) || p.codigo_barras?.toLowerCase().includes(q)); }
  if (selectedCategory.value) list = list.filter(p => p.id_categoria == selectedCategory.value);
  return list;
});

const addToCart = (prod) => {
  const ex = cart.value.find(i => i.id_producto === prod.id_producto);
  if (ex) { if (ex.qty < prod.stock_actual) ex.qty++; else alert(`Stock máximo: ${prod.stock_actual}`); }
  else cart.value.push({ id_producto: prod.id_producto, nombre: prod.nombre, precio_venta: prod.precio_venta, stock_actual: prod.stock_actual, qty: 1 });
};
const increaseQty = (item) => { if (item.qty < item.stock_actual) item.qty++; else alert(`Stock máximo: ${item.stock_actual}`); };
const decreaseQty = (item) => { if (item.qty > 1) item.qty--; else removeFromCart(item); };
const removeFromCart = (item) => { cart.value = cart.value.filter(i => i.id_producto !== item.id_producto); };
const clearCart = () => { cart.value = []; };

const calculatedTotal = computed(() => cart.value.reduce((s, i) => s + i.precio_venta * i.qty, 0));
const calculatedSubtotal = computed(() => form.value.id_tipo_comprobante === 2 ? calculatedTotal.value / 1.18 : calculatedTotal.value);
const calculatedIgv = computed(() => form.value.id_tipo_comprobante === 2 ? calculatedTotal.value - calculatedSubtotal.value : 0);

const openNewClientModal = () => { clientErrorMsg.value = ''; newClientForm.value = { nombres: '', dni_ruc: '', direccion: '', telefono: '' }; isNewClientModalOpen.value = true; };
const closeNewClientModal = () => { isNewClientModalOpen.value = false; };

const saveQuickClient = async () => {
  savingClient.value = true; clientErrorMsg.value = '';
  try { const r = await api.post('/clientes', newClientForm.value); if (r.data.success) { await loadClientes(r.data.data.id_cliente); closeNewClientModal(); } }
  catch (e) { clientErrorMsg.value = e.response?.data?.message || 'Error al registrar cliente.'; }
  finally { savingClient.value = false; }
};

const submitVenta = async () => {
  submitting.value = true;
  try {
    const r = await api.post('/ventas', {
      id_cliente: form.value.id_cliente,
      id_tipo_comprobante: form.value.id_tipo_comprobante,
      items: cart.value.map(i => ({ id_producto: i.id_producto, cantidad: i.qty }))
    });
    if (r.data.success) { successVentaData.value = r.data.data; isSuccessModalOpen.value = true; clearCart(); loadProductos(); }
  } catch (e) { alert(e.response?.data?.error || e.response?.data?.message || 'Error al registrar venta.'); }
  finally { submitting.value = false; }
};

const closeSuccessModal = () => { isSuccessModalOpen.value = false; successVentaData.value = {}; };
const printTicket = () => { window.print(); };
const formatDate = (d) => d ? new Date(d).toLocaleString('es-PE', { timeZone: 'America/Lima' }) : '';

onMounted(() => { loadProductos(); loadCategorias(); loadClientes(); });
</script>

<style scoped>
@media print {
  body * { visibility: hidden; }
  #ticket-print, #ticket-print * { visibility: visible; }
  #ticket-print { position: fixed; left: 50%; top: 0; transform: translateX(-50%); background: white; color: black; border: none; width: 300px; }
}
</style>
