<template>
  <div class="min-h-screen bg-slate-900 flex">

    <!-- Overlay móvil -->
    <div v-if="isMobileMenuOpen" @click="closeMobileMenu" class="fixed inset-0 bg-slate-950/70 z-40 md:hidden"></div>

    <!-- ── Sidebar ─────────────────────────────────── -->
    <aside :class="[
      'w-60 bg-slate-950 border-r border-slate-800 flex flex-col fixed inset-y-0 left-0 z-50 transition-transform duration-200',
      'md:translate-x-0 md:static md:flex',
      isMobileMenuOpen ? 'translate-x-0' : '-translate-x-full'
    ]">

      <!-- Logo -->
      <div class="h-14 flex items-center gap-3 px-5 border-b border-slate-800 shrink-0">
        <div class="w-8 h-8 bg-sky-600 rounded-lg flex items-center justify-center shrink-0">
          <StoreIcon class="w-4 h-4 text-white" />
        </div>
        <span class="text-sm font-bold text-slate-100">InventMax</span>
      </div>

      <!-- Navegación -->
      <nav class="flex-1 overflow-y-auto py-4 px-3 space-y-5">
        <div v-for="group in menuGroups" :key="group.title">
          <template v-if="group.items.some(i => checkRole(i.roles))">
            <p class="section-label px-2 mb-1.5">{{ group.title }}</p>
            <div class="space-y-0.5">
              <template v-for="item in group.items" :key="item.name">
                <router-link v-if="checkRole(item.roles)" :to="item.path" @click="closeMobileMenu" v-slot="{ isActive }" custom>
                  <a @click.prevent="$router.push(item.path); closeMobileMenu()" :class="[
                    'flex items-center gap-2.5 px-3 py-2 rounded-lg text-sm font-medium cursor-pointer transition-colors',
                    isActive
                      ? 'bg-sky-600 text-white'
                      : 'text-slate-400 hover:bg-slate-800 hover:text-slate-100'
                  ]">
                    <component :is="item.icon" class="w-4 h-4 shrink-0" />
                    <span>{{ item.label }}</span>
                  </a>
                </router-link>
              </template>
            </div>
          </template>
        </div>
      </nav>

      <!-- User footer -->
      <div class="p-3 border-t border-slate-800 shrink-0">
        <div class="flex items-center gap-3 px-2 mb-2">
          <div class="w-8 h-8 rounded-full bg-sky-600/20 border border-sky-600/30 flex items-center justify-center text-xs font-bold text-sky-400 shrink-0">
            {{ userInitials }}
          </div>
          <div class="min-w-0">
            <p class="text-xs font-semibold text-slate-200 truncate">{{ authStore.user?.nombres }}</p>
            <span class="badge badge-sky">{{ authStore.userRole }}</span>
          </div>
        </div>
        <button @click="handleLogout" class="btn btn-secondary btn-sm w-full mt-1">
          <LogOutIcon class="w-3.5 h-3.5 inline-block mr-2" />
          Cerrar sesión
        </button>
      </div>
    </aside>

    <!-- ── Main content ───────────────────────────── -->
    <div class="flex-1 flex flex-col min-w-0">

      <!-- Top bar -->
      <NavBar :title="currentRouteLabel" @toggleMobileMenu="toggleMobileMenu" @search="onSearch" @create="onCreate">
        <template #menu-icon>
          <MenuIcon class="w-5 h-5" />
        </template>
      </NavBar>

      <!-- Page content -->
      <main class="flex-1 p-6 overflow-y-auto">
        <router-view />
      </main>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue';
import { useRouter, useRoute } from 'vue-router';
import { useAuthStore } from '../stores/auth';
import {
  Store as StoreIcon, LayoutDashboard as DashboardIcon, FolderOpen as CategoryIcon,
  Tag as ProductIcon, Users as ClientIcon, ShoppingCart as POSIcon,
  Receipt as ReceiptIcon, History as HistoryIcon, UsersRound as UsersIcon,
  LogOut as LogOutIcon, Menu as MenuIcon
} from '@lucide/vue';
import NavBar from '../components/NavBar.vue';
// Button component unused (native buttons used instead)

const router = useRouter();
const route = useRoute();
const authStore = useAuthStore();
const isMobileMenuOpen = ref(false);

const toggleMobileMenu = () => { isMobileMenuOpen.value = !isMobileMenuOpen.value; };
const closeMobileMenu = () => { isMobileMenuOpen.value = false; };

const userInitials = computed(() => {
  if (!authStore.user?.nombres) return 'U';
  return authStore.user.nombres.split(' ').slice(0, 2).map(w => w[0]).join('').toUpperCase();
});

const handleLogout = async () => { await authStore.logout(); router.push({ name: 'Login' }); };
const checkRole = (roles) => !roles || roles.includes(authStore.user?.id_rol);

const menuGroups = [
  { title: 'General', items: [
    { name: 'Dashboard', label: 'Resumen', path: '/dashboard', icon: DashboardIcon, roles: [1,2,3] }
  ]},
  { title: 'Ventas', items: [
    { name: 'VentaPOS',        label: 'Registrar Venta',  path: '/venta',           icon: POSIcon,     roles: [1,2] },
    { name: 'VentasHistorial', label: 'Historial Ventas', path: '/ventas-historial', icon: ReceiptIcon, roles: [1,2] },
    { name: 'Clientes',        label: 'Clientes',         path: '/clientes',         icon: ClientIcon,  roles: [1,2] },
  ]},
  { title: 'Inventario', items: [
    { name: 'Productos',             label: 'Productos',    path: '/productos',  icon: ProductIcon,  roles: [1,3] },
    { name: 'Categorias',            label: 'Categorías',   path: '/categorias', icon: CategoryIcon, roles: [1,3] },
    { name: 'InventarioMovimientos', label: 'Movimientos',  path: '/inventario', icon: HistoryIcon,  roles: [1,3] },
  ]},
  { title: 'Admin', items: [
    { name: 'Usuarios', label: 'Usuarios', path: '/usuarios', icon: UsersIcon, roles: [1] }
  ]}
];

const currentRouteLabel = computed(() => {
  const p = route.path;
  for (const g of menuGroups) {
    const m = g.items.find(i => p.startsWith(i.path));
    if (m) return m.label;
  }
  return 'InventMax';
});

const onSearch = (q) => {
  // forward search to router or store — currently logs
  // console.log('search:', q);
};

const onCreate = () => {
  // shortcut for creating new entity — navigate to productos
  router.push({ path: '/productos' });
};
</script>
