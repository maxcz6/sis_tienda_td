<template>
  <div class="min-h-screen bg-slate-950 flex items-center justify-center p-4">
    <div class="w-full max-w-sm space-y-8">

      <!-- Brand -->
      <div class="text-center">
        <div class="inline-flex items-center justify-center w-12 h-12 bg-sky-600 rounded-xl mb-4">
          <StoreIcon class="w-6 h-6 text-white" />
        </div>
        <h1 class="text-2xl font-bold text-slate-100 tracking-tight">InventMax</h1>
        <p class="text-sm text-slate-500 mt-1">Sistema de Ventas e Inventario</p>
      </div>

      <!-- Card de login -->
      <div class="card p-8 space-y-5">
        <!-- Error -->
        <div v-if="errorMsg" class="flex items-start gap-3 p-3 bg-red-950/40 border border-red-800/50 rounded-lg text-sm text-red-400">
          <AlertTriangleIcon class="w-4 h-4 mt-0.5 shrink-0" />
          <span>{{ errorMsg }}</span>
        </div>

        <form @submit.prevent="handleLogin" class="space-y-4">
          <!-- Username -->
          <div class="space-y-1.5">
            <label for="username" class="block text-xs font-medium text-slate-400">Usuario</label>
            <div class="relative">
              <UserIcon class="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-500" />
              <input
                id="username" type="text" v-model="username" required
                placeholder="Ingresa tu usuario"
                class="input pl-9"
              />
            </div>
          </div>

          <!-- Password -->
          <div class="space-y-1.5">
            <label for="password" class="block text-xs font-medium text-slate-400">Contraseña</label>
            <div class="relative">
              <LockIcon class="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-500" />
              <input
                id="password" type="password" v-model="password" required
                placeholder="••••••••"
                class="input pl-9"
              />
            </div>
          </div>

          <!-- Submit -->
          <button type="submit" :disabled="loading" class="btn btn-primary w-full mt-2">
            <span v-if="loading" class="w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin inline-block mr-2"></span>
            <LogInIcon v-if="!loading" class="w-4 h-4 inline-block mr-2" />
            <span>Iniciar Sesión</span>
          </button>
        </form>
      </div>

      <!-- Quick fill -->
      <div class="text-center space-y-2">
        <p class="section-label">Cuentas de demostración</p>
        <div class="flex flex-wrap justify-center gap-2">
          <button @click="fillCreds('admin','admin123')" class="text-xs px-3 py-1.5 bg-slate-800 hover:bg-slate-700 border border-slate-700 text-slate-300 rounded-lg transition-colors">
            Admin
          </button>
          <button @click="fillCreds('cajero1','123456')" class="text-xs px-3 py-1.5 bg-slate-800 hover:bg-slate-700 border border-slate-700 text-slate-300 rounded-lg transition-colors">
            Cajero
          </button>
          <button @click="fillCreds('almacen1','123456')" class="text-xs px-3 py-1.5 bg-slate-800 hover:bg-slate-700 border border-slate-700 text-slate-300 rounded-lg transition-colors">
            Almacén
          </button>
        </div>
      </div>

    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue';
import { useRouter } from 'vue-router';
import { useAuthStore } from '../stores/auth';
import { Store as StoreIcon, User as UserIcon, Lock as LockIcon, LogIn as LogInIcon, AlertTriangle as AlertTriangleIcon } from '@lucide/vue';

const router = useRouter();
const authStore = useAuthStore();
const username = ref('');
const password = ref('');
const loading = ref(false);
const errorMsg = ref('');

const handleLogin = async () => {
  loading.value = true;
  errorMsg.value = '';
  const result = await authStore.login(username.value, password.value);
  if (result.success) {
    router.push({ name: 'Dashboard' });
  } else {
    errorMsg.value = result.message;
  }
  loading.value = false;
};

const fillCreds = (u, p) => { username.value = u; password.value = p; };
</script>
