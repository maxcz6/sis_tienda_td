<template>
  <div class="fade-in space-y-4">
    <!-- Header -->
    <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
      <p class="text-sm text-slate-400">Gestiona la información de tus clientes</p>
      <button @click="openModal()" class="btn btn-primary btn-sm w-full sm:w-auto">
        <PlusIcon class="w-3.5 h-3.5" /> Nuevo cliente
      </button>
    </div>

    <!-- Card tabla -->
    <div class="card overflow-hidden">
      <div class="px-5 py-3 border-b border-slate-700">
        <div class="relative w-full sm:max-w-xs">
          <SearchIcon class="absolute left-3 top-1/2 -translate-y-1/2 w-3.5 h-3.5 text-slate-500" />
          <input type="text" v-model="searchQuery" placeholder="Buscar por nombre o DNI/RUC..."
            class="input w-full pl-8 text-xs py-2" />
        </div>
      </div>

      <div v-if="loading" class="flex items-center justify-center py-16">
        <span class="w-6 h-6 border-2 border-sky-500/30 border-t-sky-500 rounded-full animate-spin"></span>
      </div>
      <div v-else-if="!filteredClientes.length" class="flex flex-col items-center py-16 text-slate-600">
        <InboxIcon class="w-8 h-8 mb-2" />
        <p class="text-xs">No hay clientes registrados.</p>
      </div>
      <div v-else class="table-wrap">
        <table class="data-table">
          <thead>
            <tr><th>Cliente</th><th>DNI / RUC</th><th>Teléfono</th><th>Dirección</th><th class="text-right">Acciones</th></tr>
          </thead>
          <tbody>
            <tr v-for="cli in filteredClientes" :key="cli.id_cliente">
              <td>
                <div class="flex items-center gap-2">
                  <div class="w-7 h-7 rounded-lg bg-slate-700 flex items-center justify-center shrink-0">
                    <UserIcon class="w-3.5 h-3.5 text-slate-400" />
                  </div>
                  <span class="font-medium text-slate-100">{{ cli.nombres }}</span>
                </div>
              </td>
              <td><span v-if="cli.dni_ruc" class="font-mono badge badge-slate">{{ cli.dni_ruc }}</span><span v-else class="text-slate-600">—</span></td>
              <td>
                <span v-if="cli.telefono" class="flex items-center gap-1.5 text-slate-400">
                  <PhoneIcon class="w-3 h-3 text-slate-600" /> {{ cli.telefono }}
                </span>
                <span v-else class="text-slate-600">—</span>
              </td>
              <td class="max-w-xs">
                <span v-if="cli.direccion" class="flex items-center gap-1.5 text-slate-400 truncate" :title="cli.direccion">
                  <MapPinIcon class="w-3 h-3 text-slate-600 shrink-0" /> {{ cli.direccion }}
                </span>
                <span v-else class="text-slate-600">—</span>
              </td>
              <td class="text-right">
                <div class="flex items-center justify-end gap-1">
                  <button @click="openModal(cli)" class="btn btn-secondary btn-sm"><EditIcon class="w-3 h-3" /></button>
                  <button @click="confirmDelete(cli)" class="btn btn-danger btn-sm"><TrashIcon class="w-3 h-3" /></button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Modal -->
    <div v-if="isModalOpen" class="modal-overlay">
      <div class="modal-box">
        <h3 class="text-sm font-semibold text-slate-100 mb-4">{{ isEditMode ? 'Editar cliente' : 'Nuevo cliente' }}</h3>
        <div v-if="errorMsg" class="mb-4 p-3 bg-red-950/40 border border-red-800/50 rounded-lg text-xs text-red-400">{{ errorMsg }}</div>
        <form @submit.prevent="saveCliente" class="space-y-4">
          <div class="space-y-1.5">
            <label class="block text-xs font-medium text-slate-400">Nombre / Razón social *</label>
            <input type="text" v-model="form.nombres" required maxlength="150"
              placeholder="Ej. Juan Pérez, Inversiones S.A.C." class="input" />
          </div>
          <div class="grid grid-cols-2 gap-3">
            <div class="space-y-1.5">
              <label class="block text-xs font-medium text-slate-400">DNI / RUC</label>
              <input type="text" v-model="form.dni_ruc" maxlength="20" placeholder="45678912" class="input font-mono" />
            </div>
            <div class="space-y-1.5">
              <label class="block text-xs font-medium text-slate-400">Teléfono</label>
              <input type="text" v-model="form.telefono" maxlength="20" placeholder="987654321" class="input font-mono" />
            </div>
          </div>
          <div class="space-y-1.5">
            <label class="block text-xs font-medium text-slate-400">Dirección</label>
            <input type="text" v-model="form.direccion" maxlength="255" placeholder="Av. Larco 123" class="input" />
          </div>
          <div class="flex justify-end gap-2 pt-3 border-t border-slate-700">
            <button type="button" @click="closeModal" class="btn btn-secondary btn-sm">Cancelar</button>
            <button type="submit" :disabled="saving" class="btn btn-primary btn-sm">{{ saving ? 'Guardando...' : 'Guardar' }}</button>
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
import { Plus as PlusIcon, Search as SearchIcon, Inbox as InboxIcon, Edit as EditIcon, Trash2 as TrashIcon, User as UserIcon, Phone as PhoneIcon, MapPin as MapPinIcon } from '@lucide/vue';

const route = useRoute();
const loading = ref(true), saving = ref(false);
const clientes = ref([]), searchQuery = ref('');
const isModalOpen = ref(false), isEditMode = ref(false), errorMsg = ref('');
const form = ref({ id_cliente: null, nombres: '', dni_ruc: '', direccion: '', telefono: '' });

// Watch for search query parameter from navbar
watch(() => route.query.q, (newVal) => {
  searchQuery.value = newVal || '';
}, { immediate: true });


const loadClientes = async () => {
  loading.value = true;
  try { const r = await api.get('/clientes'); if (r.data.success) clientes.value = r.data.data; }
  catch (e) { console.error(e); } finally { loading.value = false; }
};

const filteredClientes = computed(() => {
  const q = searchQuery.value.toLowerCase().trim();
  return q ? clientes.value.filter(c => c.nombres.toLowerCase().includes(q) || c.dni_ruc?.includes(q) || c.telefono?.includes(q)) : clientes.value;
});

const openModal = (cli = null) => {
  errorMsg.value = ''; isModalOpen.value = true;
  if (cli) { isEditMode.value = true; form.value = { ...cli }; }
  else { isEditMode.value = false; form.value = { id_cliente: null, nombres: '', dni_ruc: '', direccion: '', telefono: '' }; }
};
const closeModal = () => { isModalOpen.value = false; errorMsg.value = ''; };

const saveCliente = async () => {
  saving.value = true; errorMsg.value = '';
  try {
    const r = isEditMode.value ? await api.put(`/clientes/${form.value.id_cliente}`, form.value) : await api.post('/clientes', form.value);
    if (r.data.success) { loadClientes(); closeModal(); }
  } catch (e) { errorMsg.value = e.response?.data?.message || 'Error al guardar.'; }
  finally { saving.value = false; }
};

const confirmDelete = async (cli) => {
  if (!confirm(`¿Eliminar a "${cli.nombres}"?`)) return;
  try { const r = await api.delete(`/clientes/${cli.id_cliente}`); if (r.data.success) loadClientes(); }
  catch (e) { alert(e.response?.data?.message || 'Error al eliminar.'); }
};

onMounted(loadClientes);
</script>
