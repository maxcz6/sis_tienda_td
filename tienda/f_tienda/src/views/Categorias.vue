<template>
  <div class="fade-in space-y-4">

    <!-- Header -->
    <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
      <p class="text-sm text-slate-400">Administra las agrupaciones de tu catálogo</p>
      <button @click="openModal()" class="btn btn-primary btn-sm w-full sm:w-auto">
        <PlusIcon class="w-3.5 h-3.5" /> Nueva categoría
      </button>
    </div>

    <!-- Card tabla -->
    <div class="card overflow-hidden">
      <div class="px-5 py-3 border-b border-slate-700">
        <div class="relative w-full sm:max-w-xs">
          <SearchIcon class="absolute left-3 top-1/2 -translate-y-1/2 w-3.5 h-3.5 text-slate-500" />
          <input type="text" v-model="searchQuery" placeholder="Buscar categoría..."
            class="input w-full pl-8 text-xs py-2" />
        </div>
      </div>

      <div v-if="loading" class="flex items-center justify-center py-16">
        <span class="w-6 h-6 border-2 border-sky-500/30 border-t-sky-500 rounded-full animate-spin"></span>
      </div>

      <div v-else-if="!filteredCategorias.length" class="flex flex-col items-center py-16 text-slate-600">
        <InboxIcon class="w-8 h-8 mb-2" />
        <p class="text-xs">No hay categorías. Crea la primera.</p>
      </div>

      <div v-else class="table-wrap">
        <table class="data-table">
          <thead>
            <tr><th>#</th><th>Nombre</th><th>Descripción</th><th class="text-right">Acciones</th></tr>
          </thead>
          <tbody>
            <tr v-for="cat in filteredCategorias" :key="cat.id_categoria">
              <td class="font-mono text-slate-600">{{ cat.id_categoria }}</td>
              <td class="font-medium text-slate-100">{{ cat.nombre }}</td>
              <td class="text-slate-400">{{ cat.descripcion || '—' }}</td>
              <td class="text-right">
                <div class="flex items-center justify-end gap-1">
                  <button @click="openModal(cat)" class="btn btn-secondary btn-sm">
                    <EditIcon class="w-3 h-3" />
                  </button>
                  <button @click="confirmDelete(cat)" class="btn btn-danger btn-sm">
                    <TrashIcon class="w-3 h-3" />
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
      <div class="modal-box">
        <h3 class="text-sm font-semibold text-slate-100 mb-4">
          {{ isEditMode ? 'Editar categoría' : 'Nueva categoría' }}
        </h3>

        <div v-if="errorMsg" class="mb-4 p-3 bg-red-950/40 border border-red-800/50 rounded-lg text-xs text-red-400">{{ errorMsg }}</div>

        <form @submit.prevent="saveCategoria" class="space-y-4">
          <div class="space-y-1.5">
            <label class="block text-xs font-medium text-slate-400">Nombre *</label>
            <input type="text" v-model="form.nombre" required maxlength="100"
              placeholder="Ej. Bebidas, Abarrotes" class="input" />
          </div>
          <div class="space-y-1.5">
            <label class="block text-xs font-medium text-slate-400">Descripción</label>
            <textarea v-model="form.descripcion" rows="3" maxlength="255"
              placeholder="Descripción breve..." class="input resize-none"></textarea>
          </div>
          <div class="flex justify-end gap-2 pt-3 border-t border-slate-700">
            <button type="button" @click="closeModal" class="btn btn-secondary btn-sm">Cancelar</button>
            <button type="submit" :disabled="saving" class="btn btn-primary btn-sm">
              {{ saving ? 'Guardando...' : 'Guardar' }}
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
import { Plus as PlusIcon, Search as SearchIcon, Inbox as InboxIcon, Edit as EditIcon, Trash2 as TrashIcon } from '@lucide/vue';

const route = useRoute();
const loading = ref(true), saving = ref(false);
const categorias = ref([]), searchQuery = ref('');
const isModalOpen = ref(false), isEditMode = ref(false), errorMsg = ref('');
const form = ref({ id_categoria: null, nombre: '', descripcion: '' });

// Watch for search query parameter from navbar
watch(() => route.query.q, (newVal) => {
  searchQuery.value = newVal || '';
}, { immediate: true });


const loadCategorias = async () => {
  loading.value = true;
  try { const r = await api.get('/categorias'); if (r.data.success) categorias.value = r.data.data; }
  catch (e) { console.error(e); } finally { loading.value = false; }
};

const filteredCategorias = computed(() => {
  const q = searchQuery.value.toLowerCase().trim();
  return q ? categorias.value.filter(c => c.nombre.toLowerCase().includes(q) || c.descripcion?.toLowerCase().includes(q)) : categorias.value;
});

const openModal = (cat = null) => {
  errorMsg.value = ''; isModalOpen.value = true;
  if (cat) { isEditMode.value = true; form.value = { ...cat }; }
  else { isEditMode.value = false; form.value = { id_categoria: null, nombre: '', descripcion: '' }; }
};
const closeModal = () => { isModalOpen.value = false; errorMsg.value = ''; };

const saveCategoria = async () => {
  saving.value = true; errorMsg.value = '';
  try {
    const r = isEditMode.value
      ? await api.put(`/categorias/${form.value.id_categoria}`, form.value)
      : await api.post('/categorias', form.value);
    if (r.data.success) { loadCategorias(); closeModal(); }
  } catch (e) { errorMsg.value = e.response?.data?.message || 'Error al guardar.'; }
  finally { saving.value = false; }
};

const confirmDelete = async (cat) => {
  if (!confirm(`¿Eliminar "${cat.nombre}"?`)) return;
  try { const r = await api.delete(`/categorias/${cat.id_categoria}`); if (r.data.success) loadCategorias(); }
  catch (e) { alert(e.response?.data?.message || 'Error al eliminar.'); }
};

onMounted(loadCategorias);
</script>
