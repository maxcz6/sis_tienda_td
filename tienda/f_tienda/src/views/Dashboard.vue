<template>
  <div class="fade-in space-y-5">

    <!-- ── Skeleton ───────────────────────────────── -->
    <div v-if="loading" class="space-y-5">
      <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
        <div v-for="i in 3" :key="i" class="h-24 bg-slate-800 rounded-xl border border-slate-700 animate-pulse"></div>
      </div>
      <div class="grid grid-cols-1 lg:grid-cols-3 gap-4">
        <div class="h-64 lg:col-span-2 bg-slate-800 rounded-xl border border-slate-700 animate-pulse"></div>
        <div class="h-64 bg-slate-800 rounded-xl border border-slate-700 animate-pulse"></div>
      </div>
    </div>

    <template v-else>
      <!-- ── Stat cards ──────────────────────────── -->
      <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">

        <!-- Ventas hoy -->
        <div class="card p-5 flex items-center gap-4">
          <div class="w-10 h-10 bg-emerald-500/10 rounded-lg flex items-center justify-center shrink-0">
            <DollarIcon class="w-5 h-5 text-emerald-400" />
          </div>
          <div>
            <p class="section-label">Ventas del día</p>
            <p class="text-xl font-bold text-slate-100 mt-0.5">S/ {{ stats.ventas_hoy.toFixed(2) }}</p>
          </div>
        </div>

        <!-- Productos -->
        <div class="card p-5 flex items-center gap-4">
          <div class="w-10 h-10 bg-sky-500/10 rounded-lg flex items-center justify-center shrink-0">
            <BoxIcon class="w-5 h-5 text-sky-400" />
          </div>
          <div>
            <p class="section-label">Productos activos</p>
            <p class="text-xl font-bold text-slate-100 mt-0.5">{{ stats.total_productos }}</p>
          </div>
        </div>

        <!-- Bajo stock -->
        <div @click="scrollToLowStock" class="card p-5 flex items-center gap-4 cursor-pointer hover:border-amber-600/50 transition-colors"
          :class="stats.bajo_stock_count > 0 ? 'border-amber-600/30' : ''">
          <div :class="['w-10 h-10 rounded-lg flex items-center justify-center shrink-0',
            stats.bajo_stock_count > 0 ? 'bg-amber-500/10' : 'bg-slate-700']">
            <AlertIcon class="w-5 h-5" :class="stats.bajo_stock_count > 0 ? 'text-amber-400' : 'text-slate-500'" />
          </div>
          <div>
            <p class="section-label">Stock bajo</p>
            <p class="text-xl font-bold mt-0.5" :class="stats.bajo_stock_count > 0 ? 'text-amber-400' : 'text-slate-100'">
              {{ stats.bajo_stock_count }}
            </p>
          </div>
          <span v-if="stats.bajo_stock_count > 0" class="badge badge-amber ml-auto">Alerta</span>
        </div>
      </div>

      <!-- ── Chart + Top productos ───────────────── -->
      <div class="grid grid-cols-1 lg:grid-cols-3 gap-4">

        <!-- Bar chart -->
        <div class="card p-5 lg:col-span-2">
          <div class="mb-5">
            <h3 class="text-sm font-semibold text-slate-100">Ventas — últimos 7 días</h3>
            <p class="text-xs text-slate-500 mt-0.5">Ingresos en Soles (S/)</p>
          </div>
          <div class="flex items-end gap-2 h-44">
            <div v-for="day in stats.ventas_semanales" :key="day.fecha"
              class="flex flex-col items-center gap-1.5 flex-1 group">
              <span class="text-[10px] text-slate-500 opacity-0 group-hover:opacity-100 transition-opacity">
                S/{{ day.total.toFixed(0) }}
              </span>
              <div class="w-full bg-sky-600 rounded-t-sm transition-all duration-500 ease-out group-hover:bg-sky-500"
                :style="{ height: getBarHeight(day.total) + 'px' }">
              </div>
              <span class="text-[10px] text-slate-500">{{ day.fecha }}</span>
            </div>
          </div>
        </div>

        <!-- Top productos -->
        <div class="card p-5">
          <h3 class="text-sm font-semibold text-slate-100 mb-4">Más vendidos</h3>
          <div v-if="!stats.top_productos.length" class="flex flex-col items-center justify-center py-8 text-slate-600">
            <TrendingUpIcon class="w-7 h-7 mb-2" />
            <p class="text-xs">Sin datos aún</p>
          </div>
          <div v-else class="space-y-3">
            <div v-for="(prod, idx) in stats.top_productos" :key="prod.nombre"
              class="flex items-center gap-3">
              <span class="w-5 h-5 rounded bg-slate-700 flex items-center justify-center text-[10px] font-bold text-slate-400 shrink-0">
                {{ idx + 1 }}
              </span>
              <div class="min-w-0 flex-1">
                <p class="text-xs font-medium text-slate-200 truncate">{{ prod.nombre }}</p>
                <p class="text-[10px] text-slate-500">{{ prod.cantidad }} uds.</p>
              </div>
              <span class="text-xs font-semibold text-slate-100 shrink-0">S/ {{ prod.total_monto.toFixed(2) }}</span>
            </div>
          </div>
        </div>
      </div>

      <!-- ── Bajo stock detail ───────────────────── -->
      <div id="low-stock-section" class="card">
        <div class="flex items-center justify-between px-5 py-4 border-b border-slate-700">
          <div class="flex items-center gap-2">
            <AlertIcon class="w-4 h-4 text-amber-400" />
            <h3 class="text-sm font-semibold text-slate-100">Alertas de reposición</h3>
          </div>
          <span class="text-xs text-slate-500">{{ stats.bajo_stock_productos.length }} producto(s)</span>
        </div>

        <div v-if="!stats.bajo_stock_productos.length" class="flex flex-col items-center py-10 text-slate-600">
          <CheckCircleIcon class="w-7 h-7 text-emerald-600/40 mb-2" />
          <p class="text-xs">Todo en orden. Sin productos con stock bajo.</p>
        </div>

        <div v-else class="table-wrap">
          <table class="data-table">
            <thead>
              <tr>
                <th>Código</th>
                <th>Producto</th>
                <th>Categoría</th>
                <th class="text-center">Mín.</th>
                <th class="text-center">Actual</th>
                <th>Estado</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="p in stats.bajo_stock_productos" :key="p.id_producto">
                <td class="font-mono text-slate-500">{{ p.codigo_barras || '—' }}</td>
                <td class="font-medium text-slate-100">{{ p.nombre }}</td>
                <td>{{ p.categoria?.nombre }}</td>
                <td class="text-center">{{ p.stock_minimo }}</td>
                <td class="text-center"><span class="badge badge-amber">{{ p.stock_actual }}</span></td>
                <td><span class="badge badge-red">Reabastecer</span></td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </template>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import axios from 'axios';
import { DollarSign as DollarIcon, Box as BoxIcon, AlertTriangle as AlertIcon,
  CheckCircle2 as CheckCircleIcon, TrendingUp as TrendingUpIcon } from '@lucide/vue';

const loading = ref(true);
const stats = ref({ ventas_hoy: 0, total_productos: 0, bajo_stock_count: 0, ventas_semanales: [], top_productos: [], bajo_stock_productos: [] });

const loadStats = async () => {
  loading.value = true;
  try {
    const r = await axios.get('/dashboard/stats');
    if (r.data.success) stats.value = r.data.data;
  } catch (e) { console.error(e); }
  finally { loading.value = false; }
};

const getBarHeight = (total) => {
  const max = Math.max(...stats.value.ventas_semanales.map(d => d.total), 1);
  return Math.max((total / max) * 140, 4);
};

const scrollToLowStock = () => {
  document.getElementById('low-stock-section')?.scrollIntoView({ behavior: 'smooth', block: 'start' });
};

onMounted(loadStats);
</script>
