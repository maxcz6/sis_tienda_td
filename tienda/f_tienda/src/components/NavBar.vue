<template>
  <header class="h-14 bg-slate-900/95 backdrop-blur-sm border-b border-slate-800/80 flex items-center justify-between px-4 md:px-6 sticky top-0 z-30">
    
    <!-- Left: Title & Mobile menu -->
    <div class="flex items-center gap-3 shrink-0 min-w-0">
      <button @click="$emit('toggleMobileMenu')" class="p-2 rounded-lg text-slate-400 hover:bg-slate-800 hover:text-slate-100 md:hidden transition-colors">
        <slot name="menu-icon">☰</slot>
      </button>
      <h2 class="text-sm font-semibold text-slate-100 truncate hidden lg:block">{{ title }}</h2>
    </div>

    <!-- Center: Modern Minimalist Search Bar with Auto-suggestions -->
    <div class="flex items-center flex-1 max-w-lg px-4 mx-auto relative">
      <div class="relative flex-1 group">
        <!-- Search Icon -->
        <span class="absolute inset-y-0 left-3 flex items-center text-slate-500 pointer-events-none group-focus-within:text-sky-400 transition-colors">
          <svg class="w-4 h-4" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
          </svg>
        </span>

        <!-- Input -->
        <input
          ref="searchInput"
          v-model="q"
          @input="onInput"
          @focus="onFocus"
          @blur="onBlur"
          type="text"
          placeholder="Buscar..."
          class="w-full bg-slate-950/40 hover:bg-slate-950/60 focus:bg-slate-950/90 border border-slate-800/80 hover:border-slate-700/50 focus:border-sky-500/70 rounded-lg py-1.5 pl-9 pr-8 text-xs text-slate-200 placeholder-slate-500 focus:ring-2 focus:ring-sky-500/10 focus:outline-none transition-all duration-200"
        />

        <!-- Shortcut Hint (visible when not focused and empty) -->
        <span 
          v-if="!q && !isFocused"
          class="absolute inset-y-0 right-3 flex items-center pointer-events-none"
        >
          <kbd class="hidden sm:inline-flex items-center px-1.5 py-0.5 text-[9px] font-medium text-slate-500 bg-slate-900 border border-slate-800 rounded font-mono select-none">
            Ctrl K
          </kbd>
        </span>

        <!-- Clear Button (visible when input has text) -->
        <button
          v-else-if="q"
          @click="clearSearch"
          type="button"
          class="absolute inset-y-0 right-2 flex items-center px-1 text-slate-500 hover:text-slate-300 transition-colors"
        >
          <svg class="w-4 h-4" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12" />
          </svg>
        </button>
      </div>

      <!-- Dropdown panel -->
      <div 
        v-if="isFocused && q.trim().length >= 1 && hasSuggestions"
        class="absolute top-full left-4 right-4 mt-1 bg-slate-900 border border-slate-800 rounded-lg shadow-2xl max-h-[380px] overflow-y-auto z-50 divide-y divide-slate-800/60"
        @mousedown.prevent
      >
        <!-- Productos Matches -->
        <div v-if="filteredSuggestions.productos.length">
          <div class="text-[9px] font-bold tracking-wider text-slate-500 uppercase px-3 py-1.5 bg-slate-950/20 select-none">
            Productos
          </div>
          <div class="divide-y divide-slate-800/30">
            <div 
              v-for="p in filteredSuggestions.productos" 
              :key="p.id_producto"
              @click="selectSuggestion('producto', p)"
              class="px-3 py-2 text-xs text-slate-300 hover:bg-slate-800/80 hover:text-white cursor-pointer flex items-center justify-between transition-colors"
            >
              <div class="min-w-0 pr-2">
                <p class="font-medium truncate text-slate-200">{{ p.nombre }}</p>
                <span class="text-[10px] text-slate-500 font-mono">{{ p.codigo_barras || 'Sin código' }}</span>
              </div>
              <div class="text-right shrink-0 text-[10px] font-mono text-slate-400">
                <span>S/ {{ parseFloat(p.precio_venta).toFixed(2) }}</span>
                <span class="mx-1.5 text-slate-600">|</span>
                <span :class="p.stock_actual <= p.stock_minimo ? 'text-amber-400 font-medium' : 'text-slate-400'">
                  Stock: {{ p.stock_actual }}
                </span>
              </div>
            </div>
          </div>
        </div>

        <!-- Clientes Matches -->
        <div v-if="filteredSuggestions.clientes.length">
          <div class="text-[9px] font-bold tracking-wider text-slate-500 uppercase px-3 py-1.5 bg-slate-950/20 select-none">
            Clientes
          </div>
          <div class="divide-y divide-slate-800/30">
            <div 
              v-for="c in filteredSuggestions.clientes" 
              :key="c.id_cliente"
              @click="selectSuggestion('cliente', c)"
              class="px-3 py-2 text-xs text-slate-300 hover:bg-slate-800/80 hover:text-white cursor-pointer flex items-center justify-between transition-colors"
            >
              <div class="min-w-0 pr-2">
                <p class="font-medium truncate text-slate-200">{{ c.nombres }}</p>
                <span class="text-[10px] text-slate-500 font-mono">{{ c.telefono || 'Sin teléfono' }}</span>
              </div>
              <span v-if="c.dni_ruc" class="shrink-0 text-[10px] font-mono text-slate-400 bg-slate-950/40 px-1.5 py-0.5 rounded border border-slate-800">
                {{ c.dni_ruc }}
              </span>
            </div>
          </div>
        </div>

        <!-- Categorias Matches -->
        <div v-if="filteredSuggestions.categorias.length">
          <div class="text-[9px] font-bold tracking-wider text-slate-500 uppercase px-3 py-1.5 bg-slate-950/20 select-none">
            Categorías
          </div>
          <div class="divide-y divide-slate-800/30">
            <div 
              v-for="cat in filteredSuggestions.categorias" 
              :key="cat.id_categoria"
              @click="selectSuggestion('categoria', cat)"
              class="px-3 py-2 text-xs text-slate-300 hover:bg-slate-800/80 hover:text-white cursor-pointer flex items-center justify-between transition-colors"
            >
              <span class="font-medium text-slate-200">{{ cat.nombre }}</span>
              <span class="text-[10px] text-slate-500 italic max-w-[200px] truncate pr-1">{{ cat.descripcion || 'Sin descripción' }}</span>
            </div>
          </div>
        </div>

        <!-- Paginas Matches -->
        <div v-if="filteredSuggestions.paginas.length">
          <div class="text-[9px] font-bold tracking-wider text-slate-500 uppercase px-3 py-1.5 bg-slate-950/20 select-none">
            Navegación
          </div>
          <div class="divide-y divide-slate-800/30">
            <div 
              v-for="pag in filteredSuggestions.paginas" 
              :key="pag.path"
              @click="selectSuggestion('pagina', pag)"
              class="px-3 py-2 text-xs text-slate-300 hover:bg-slate-800/80 hover:text-white cursor-pointer flex items-center justify-between transition-colors"
            >
              <span class="font-medium text-slate-200 flex items-center gap-1.5">
                <svg class="w-3.5 h-3.5 text-sky-400" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" d="M13.5 6H5.25A2.25 2.25 0 003 8.25v10.5A2.25 2.25 0 005.25 21h10.5A2.25 2.25 0 0018 18.75V10.5m-10.5 6L21 3m0 0h-5.25M21 3v5.25" />
                </svg>
                {{ pag.label }}
              </span>
              <span class="text-[9px] text-slate-500 font-mono">{{ pag.path }}</span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Right: Connection Status -->
    <div class="flex items-center gap-3 shrink-0">
      <ConnectionStatus />
    </div>
  </header>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted, h } from 'vue';
import { useRouter } from 'vue-router';
import axios from 'axios';
import { useConnectionStore } from '../stores/connection'

const ConnectionStatus = {
  setup(){
    const conn = useConnectionStore()
    return () => {
      const online = conn.online
      return (
        // Use a small inline render fallback when not using SFC for this tiny component
        h('div', { class: 'flex items-center gap-2' }, [
          h('span', { class: ['w-1.5 h-1.5 rounded-full', online ? 'bg-emerald-500 animate-pulse' : 'bg-red-500'] }),
          h('span', { class: ['text-[11px] hidden lg:inline', 'text-slate-500'] }, online ? 'En línea' : 'Offline')
        ])
      )
    }
  }
}

const props = defineProps({
  title: { type: String, default: 'InventMax' }
});

const emit = defineEmits(['search', 'toggleMobileMenu']);

const router = useRouter();
const q = ref('');
const searchInput = ref(null);
const isFocused = ref(false);

// Caching suggestable data
const productos = ref([]);
const clientes = ref([]);
const categorias = ref([]);
const hasFetched = ref(false);
const isFetching = ref(false);

const fetchData = async () => {
  if (hasFetched.value || isFetching.value) return;
  isFetching.value = true;
  try {
    const [resProd, resCli, resCat] = await Promise.all([
      axios.get('/productos').catch(() => ({ data: { data: [] } })),
      axios.get('/clientes').catch(() => ({ data: { data: [] } })),
      axios.get('/categorias').catch(() => ({ data: { data: [] } }))
    ]);
    productos.value = resProd.data?.data || [];
    clientes.value = resCli.data?.data || [];
    categorias.value = resCat.data?.data || [];
    hasFetched.value = true;
  } catch (e) {
    console.error('Error al cargar datos de sugerencias:', e);
  } finally {
    isFetching.value = false;
  }
};

const onFocus = () => {
  isFocused.value = true;
  fetchData();
};

const onBlur = () => {
  // Delay blur to allow clicks on dropdown items
  setTimeout(() => {
    isFocused.value = false;
  }, 200);
};

const onInput = () => {
  emit('search', q.value);
};

const clearSearch = () => {
  q.value = '';
  emit('search', '');
  searchInput.value?.focus();
};

const selectSuggestion = (type, item) => {
  q.value = '';
  isFocused.value = false;
  emit('search', '');

  if (type === 'producto') {
    router.push({ path: '/productos', query: { q: item.nombre } });
  } else if (type === 'cliente') {
    router.push({ path: '/clientes', query: { q: item.nombres } });
  } else if (type === 'categoria') {
    router.push({ path: '/categorias', query: { q: item.nombre } });
  } else if (type === 'pagina') {
    router.push({ path: item.path });
  }
};

const filteredSuggestions = computed(() => {
  const query = q.value.toLowerCase().trim();
  if (!query) return { productos: [], clientes: [], categorias: [], paginas: [] };

  // 1. Filter Products
  const prodMatches = productos.value
    .filter(p => p.nombre.toLowerCase().includes(query) || p.codigo_barras?.toLowerCase().includes(query))
    .slice(0, 4);

  // 2. Filter Clients
  const cliMatches = clientes.value
    .filter(c => c.nombres.toLowerCase().includes(query) || c.dni_ruc?.toLowerCase().includes(query))
    .slice(0, 4);

  // 3. Filter Categories
  const catMatches = categorias.value
    .filter(cat => cat.nombre.toLowerCase().includes(query))
    .slice(0, 3);

  // 4. Filter Navigation/Pages
  const pagesList = [
    { label: 'Registrar Venta (POS)', path: '/venta', keywords: ['venta', 'pos', 'boleta', 'factura', 'caja'] },
    { label: 'Catálogo de Productos', path: '/productos', keywords: ['producto', 'inventario', 'catalogo', 'codigo'] },
    { label: 'Listado de Clientes', path: '/clientes', keywords: ['cliente', 'dni', 'ruc', 'razon'] },
    { label: 'Categorías de Productos', path: '/categorias', keywords: ['categoria', 'grupo'] },
    { label: 'Movimientos de Inventario', path: '/inventario', keywords: ['movimiento', 'inventario', 'kardex', 'almacen', 'entrada', 'salida'] },
    { label: 'Gestión de Usuarios', path: '/usuarios', keywords: ['usuario', 'roles', 'admin', 'cajero'] },
    { label: 'Resumen de Dashboard', path: '/dashboard', keywords: ['dashboard', 'resumen', 'estadisticas', 'graficos'] }
  ];
  
  const pageMatches = pagesList
    .filter(p => p.label.toLowerCase().includes(query) || p.keywords.some(k => k.includes(query)))
    .slice(0, 3);

  return {
    productos: prodMatches,
    clientes: cliMatches,
    categorias: catMatches,
    paginas: pageMatches
  };
});

const hasSuggestions = computed(() => {
  const sug = filteredSuggestions.value;
  return sug.productos.length > 0 || sug.clientes.length > 0 || sug.categorias.length > 0 || sug.paginas.length > 0;
});

const handleKeyDown = (e) => {
  // Focus search input when user presses Ctrl+K or Cmd+K
  if ((e.ctrlKey || e.metaKey) && e.key.toLowerCase() === 'k') {
    e.preventDefault();
    searchInput.value?.focus();
    fetchData();
  }
};

onMounted(() => {
  window.addEventListener('keydown', handleKeyDown);
  searchInput.value?.addEventListener('focus', onFocus);
  searchInput.value?.addEventListener('blur', onBlur);
});

onUnmounted(() => {
  window.removeEventListener('keydown', handleKeyDown);
});
</script>
