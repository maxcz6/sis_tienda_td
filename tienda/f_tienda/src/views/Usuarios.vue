<template>
  <div class="space-y-5 fade-in select-none">

    <!-- Header -->
    <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
      <p class="text-sm text-slate-400">Administra los accesos y roles del personal al sistema</p>
      <button @click="openModal()" class="btn btn-primary btn-sm w-full sm:w-auto">
        <PlusIcon class="w-4 h-4" />
        Nuevo Usuario
      </button>
    </div>

    <!-- Search Bar -->
    <div class="card p-4">
      <div class="relative w-full sm:max-w-xs">
        <span class="absolute inset-y-0 left-3 flex items-center text-slate-500 pointer-events-none">
          <SearchIcon class="w-4 h-4" />
        </span>
        <input
          type="text"
          v-model="searchQuery"
          placeholder="Buscar por nombre o usuario..."
          class="input w-full pl-9"
        />
      </div>
    </div>

    <!-- Users Table -->
    <div class="card overflow-hidden">
      <!-- Loading -->
      <div v-if="loading" class="flex flex-col items-center justify-center py-20 gap-3 text-slate-500">
        <span class="w-8 h-8 border-2 border-sky-500/30 border-t-sky-500 rounded-full animate-spin"></span>
        <p class="text-xs">Cargando personal...</p>
      </div>

      <!-- Empty -->
      <div v-else-if="filteredUsuarios.length === 0" class="flex flex-col items-center justify-center py-20 gap-3 text-slate-500">
        <InboxIcon class="w-12 h-12 text-slate-700" />
        <p class="text-xs">No se encontraron colaboradores registrados</p>
      </div>

      <!-- Table -->
      <div v-else class="table-wrap">
        <table class="data-table">
          <thead>
            <tr>
              <th>Nombre / Usuario</th>
              <th>Rol</th>
              <th>Estado</th>
              <th class="text-right">Acciones</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="user in filteredUsuarios" :key="user.id_usuario">
              <!-- Nombre / Username -->
              <td>
                <div class="flex items-center gap-3">
                  <div class="w-8 h-8 rounded-lg bg-sky-500/10 border border-sky-500/20 flex items-center justify-center text-sky-400 shrink-0">
                    <UserIcon class="w-3.5 h-3.5" />
                  </div>
                  <div>
                    <p class="font-semibold text-slate-100 text-sm">{{ user.nombres }}</p>
                    <span class="text-xs text-slate-500 font-mono">@{{ user.username }}</span>
                  </div>
                </div>
              </td>

              <!-- Rol -->
              <td>
                <span
                  :class="[
                    'badge',
                    user.id_rol === 1 ? 'badge-sky' :
                    user.id_rol === 2 ? 'badge-emerald' :
                    'badge-amber'
                  ]"
                >
                  {{ user.rol?.nombre || 'Colaborador' }}
                </span>
              </td>

              <!-- Estado -->
              <td>
                <span v-if="user.estado" class="badge badge-emerald">
                  <span class="w-1.5 h-1.5 rounded-full bg-emerald-400 inline-block"></span>
                  Activo
                </span>
                <span v-else class="badge badge-red">
                  <span class="w-1.5 h-1.5 rounded-full bg-red-400 inline-block"></span>
                  Inactivo
                </span>
              </td>

              <!-- Acciones -->
              <td class="text-right">
                <div class="flex items-center justify-end gap-2">
                  <button @click="openModal(user)" class="btn btn-secondary btn-sm" title="Editar">
                    <EditIcon class="w-3.5 h-3.5" />
                  </button>
                  <button
                    :disabled="user.id_usuario === 1"
                    @click="confirmDelete(user)"
                    class="btn btn-danger btn-sm disabled:opacity-30 disabled:cursor-not-allowed"
                    title="Eliminar / Desactivar"
                  >
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
      <div class="modal-box max-w-md">
        <!-- Modal Header -->
        <div class="flex items-center justify-between mb-5">
          <h3 class="text-base font-semibold text-slate-100">
            {{ isEditMode ? 'Editar Usuario' : 'Nuevo Usuario' }}
          </h3>
          <button @click="closeModal" class="text-slate-500 hover:text-slate-300 transition">
            <span class="text-lg leading-none">&times;</span>
          </button>
        </div>

        <!-- Error -->
        <div v-if="errorMsg" class="mb-4 p-3 bg-red-500/10 border border-red-500/20 text-red-400 text-xs rounded-lg">
          {{ errorMsg }}
        </div>

        <form @submit.prevent="saveUsuario" class="space-y-4">
          <!-- Nombres -->
          <div class="space-y-1.5">
            <label class="section-label">Nombres y Apellidos</label>
            <input
              type="text"
              v-model="form.nombres"
              required
              maxlength="150"
              placeholder="Ej. Juan Pérez Ramos"
              class="input w-full"
            />
          </div>

          <!-- Username + Rol -->
          <div class="grid grid-cols-2 gap-4">
            <div class="space-y-1.5">
              <label class="section-label">Usuario (Login)</label>
              <input
                type="text"
                v-model="form.username"
                required
                maxlength="50"
                placeholder="Ej. jperez"
                class="input w-full font-mono"
              />
            </div>
            <div class="space-y-1.5">
              <label class="section-label">Rol de Acceso</label>
              <select
                v-model="form.id_rol"
                required
                :disabled="form.id_usuario === 1"
                class="input w-full disabled:opacity-40 disabled:cursor-not-allowed"
              >
                <option value="" disabled>Seleccionar...</option>
                <option v-for="rol in roles" :key="rol.id_rol" :value="rol.id_rol">
                  {{ rol.nombre }}
                </option>
              </select>
            </div>
          </div>

          <!-- Contraseña -->
          <div class="space-y-1.5">
            <div class="flex items-center justify-between">
              <label class="section-label">Contraseña</label>
              <span v-if="isEditMode" class="text-xs text-slate-500">Dejar en blanco para mantener actual</span>
            </div>
            <input
              type="password"
              v-model="form.password"
              :required="!isEditMode"
              placeholder="Contraseña del usuario..."
              class="input w-full"
            />
          </div>

          <!-- Estado -->
          <div v-if="form.id_usuario !== 1" class="flex items-center gap-2.5 pt-1">
            <input
              type="checkbox"
              id="estado"
              v-model="form.estado"
              class="w-4 h-4 rounded border-slate-700 bg-slate-900 text-sky-600 focus:ring-sky-500/20 focus:ring-offset-0 focus:outline-none"
            />
            <label for="estado" class="text-sm text-slate-300 cursor-pointer">Colaborador activo</label>
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
import { ref, computed, onMounted } from 'vue';
import axios from 'axios';
import api from '../services/api';
import { 
  Plus as PlusIcon, 
  Search as SearchIcon, 
  Inbox as InboxIcon, 
  Edit as EditIcon, 
  Trash2 as TrashIcon,
  User as UserIcon
} from '@lucide/vue';

const loading = ref(true);
const saving = ref(false);
const usuarios = ref([]);
const roles = ref([]);
const searchQuery = ref('');

// Modal y Formulario
const isModalOpen = ref(false);
const isEditMode = ref(false);
const errorMsg = ref('');
const form = ref({
  id_usuario: null,
  nombres: '',
  username: '',
  password: '',
  id_rol: '',
  estado: true
});

const loadUsuarios = async () => {
  loading.value = true;
  try {
    const response = await api.get('/usuarios');
    if (response.data.success) {
      usuarios.value = response.data.data;
    }
  } catch (err) {
    console.error('Error al cargar usuarios:', err);
  } finally {
    loading.value = false;
  }
};

const loadRoles = async () => {
  try {
    const response = await api.get('/roles');
    if (response.data.success) {
      roles.value = response.data.data;
    }
  } catch (err) {
    console.error('Error al cargar roles:', err);
  }
};

const filteredUsuarios = computed(() => {
  if (!searchQuery.value.trim()) return usuarios.value;
  const q = searchQuery.value.toLowerCase().trim();
  return usuarios.value.filter(user => 
    user.nombres.toLowerCase().includes(q) || 
    user.username.toLowerCase().includes(q)
  );
});

const openModal = (user = null) => {
  errorMsg.value = '';
  isModalOpen.value = true;
  if (user) {
    isEditMode.value = true;
    form.value = { 
      ...user,
      password: '' // Contraseña en blanco por seguridad al cargar
    };
  } else {
    isEditMode.value = false;
    form.value = {
      id_usuario: null,
      nombres: '',
      username: '',
      password: '',
      id_rol: roles.value[1]?.id_rol || '', // Cajero por defecto si existe
      estado: true
    };
  }
};

const closeModal = () => {
  isModalOpen.value = false;
  errorMsg.value = '';
};

const saveUsuario = async () => {
  saving.value = true;
  errorMsg.value = '';
  try {
    let response;
    
    // Preparar datos filtrando contraseña vacía en edición
    const payload = { ...form.value };
    if (isEditMode.value && !payload.password) {
      delete payload.password;
    }

    if (isEditMode.value) {
      response = await api.put(`/usuarios/${form.value.id_usuario}`, payload);
    } else {
      response = await api.post('/usuarios', payload);
    }
    
    if (response.data.success) {
      loadUsuarios();
      closeModal();
    }
  } catch (err) {
    console.error('Error al guardar usuario:', err);
    errorMsg.value = err.response?.data?.message || 'Error al guardar el colaborador. Por favor revisa los datos.';
  } finally {
    saving.value = false;
  }
};

const confirmDelete = async (user) => {
  const confirmed = confirm(`¿Estás seguro de que deseas eliminar o desactivar al colaborador "${user.nombres}"?`);
  if (!confirmed) return;

  try {
    const response = await api.delete(`/usuarios/${user.id_usuario}`);
    if (response.data.success) {
      alert(response.data.message);
      loadUsuarios();
    }
  } catch (err) {
    console.error('Error al eliminar usuario:', err);
    alert(err.response?.data?.message || 'Error al eliminar el colaborador.');
  }
};

onMounted(() => {
  loadUsuarios();
  loadRoles();
});
</script>
