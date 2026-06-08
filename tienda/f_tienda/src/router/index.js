import { createRouter, createWebHistory } from 'vue-router';
import { useAuthStore } from '../stores/auth';

import Login from '../views/Login.vue';
import Layout from '../views/Layout.vue';
import Dashboard from '../views/Dashboard.vue';
import Categorias from '../views/Categorias.vue';
import Clientes from '../views/Clientes.vue';
import Productos from '../views/Productos.vue';
import VentaPOS from '../views/VentaPOS.vue';
import VentasHistorial from '../views/VentasHistorial.vue';
import InventarioMovimientos from '../views/InventarioMovimientos.vue';
import Usuarios from '../views/Usuarios.vue';

const routes = [
  {
    path: '/login',
    name: 'Login',
    component: Login,
    meta: { requiresGuest: true }
  },
  {
    path: '/',
    component: Layout,
    meta: { requiresAuth: true },
    children: [
      {
        path: '',
        redirect: '/dashboard'
      },
      {
        path: 'dashboard',
        name: 'Dashboard',
        component: Dashboard
      },
      {
        path: 'categorias',
        name: 'Categorias',
        component: Categorias,
        meta: { allowedRoles: [1, 3] } // Admin and Almacenero
      },
      {
        path: 'productos',
        name: 'Productos',
        component: Productos,
        meta: { allowedRoles: [1, 3] } // Admin and Almacenero
      },
      {
        path: 'clientes',
        name: 'Clientes',
        component: Clientes,
        meta: { allowedRoles: [1, 2] } // Admin and Cajero
      },
      {
        path: 'venta',
        name: 'VentaPOS',
        component: VentaPOS,
        meta: { allowedRoles: [1, 2] } // Admin and Cajero
      },
      {
        path: 'ventas-historial',
        name: 'VentasHistorial',
        component: VentasHistorial,
        meta: { allowedRoles: [1, 2] } // Admin and Cajero
      },
      {
        path: 'inventario',
        name: 'InventarioMovimientos',
        component: InventarioMovimientos,
        meta: { allowedRoles: [1, 3] } // Admin and Almacenero
      },
      {
        path: 'usuarios',
        name: 'Usuarios',
        component: Usuarios,
        meta: { allowedRoles: [1] } // Only Admin
      }
    ]
  },
  {
    path: '/:pathMatch(.*)*',
    redirect: '/dashboard'
  }
];

const router = createRouter({
  history: createWebHistory(),
  routes
});

// Guardias globales de navegación (Vue Router 4 - return-based)
router.beforeEach((to, from) => {
  const authStore = useAuthStore();
  const isAuthenticated = authStore.isAuthenticated;

  if (to.matched.some(r => r.meta.requiresAuth)) {
    if (!isAuthenticated) return { name: 'Login' };
    const userRole = authStore.user?.id_rol;
    const allowedRoles = to.meta.allowedRoles;
    if (allowedRoles && !allowedRoles.includes(userRole)) return { name: 'Dashboard' };
    return true;
  }

  if (to.matched.some(r => r.meta.requiresGuest)) {
    if (isAuthenticated) return { name: 'Dashboard' };
    return true;
  }

  return true;
});

export default router;
