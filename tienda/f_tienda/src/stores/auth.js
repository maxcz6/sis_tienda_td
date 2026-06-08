import { defineStore } from 'pinia';
import axios from 'axios';
import api from '../services/api';

// Configurar URL base de axios para conectarse a Laravel API
// Si corre en Render se puede parametrizar, localmente es http://localhost:8000 o similar
axios.defaults.baseURL = import.meta.env.VITE_API_URL || 'http://localhost:8000/api';

export const useAuthStore = defineStore('auth', {
  state: () => ({
    user: JSON.parse(localStorage.getItem('user')) || null,
    token: localStorage.getItem('token') || null,
    loading: false,
    error: null
  }),
  getters: {
    isAuthenticated: (state) => !!state.token,
    isAdmin: (state) => state.user?.id_rol === 1,
    isCajero: (state) => state.user?.id_rol === 2,
    isAlmacenero: (state) => state.user?.id_rol === 3,
    userRole: (state) => state.user?.rol || 'SIN ROL'
  },
  actions: {
    async login(username, password) {
      this.loading = true;
      this.error = null;
      try {
      const response = await api.post('/login', { username, password });
        if (response.data.success) {
          this.token = response.data.access_token;
          this.user = response.data.user;
          
          localStorage.setItem('token', this.token);
          localStorage.setItem('user', JSON.stringify(this.user));
          
          // Configurar token en axios + api
          axios.defaults.headers.common['Authorization'] = `Bearer ${this.token}`;
          api.defaults.headers.common['Authorization'] = `Bearer ${this.token}`;
          return { success: true };
        } else {
          this.error = response.data.message || 'Error de inicio de sesión';
          return { success: false, message: this.error };
        }
      } catch (err) {
        console.error('Login error:', err);
        this.error = err.response?.data?.message || 'Error de conexión con el servidor';
        return { success: false, message: this.error };
      } finally {
        this.loading = false;
      }
    },
    async logout() {
      try {
        if (this.token) {
          // Configurar token para esta petición por seguridad
          axios.defaults.headers.common['Authorization'] = `Bearer ${this.token}`;
          api.defaults.headers.common['Authorization'] = `Bearer ${this.token}`;
          await api.post('/logout');
        }
      } catch (err) {
        console.error('Logout API error:', err);
      } finally {
        this.token = null;
        this.user = null;
        localStorage.removeItem('token');
        localStorage.removeItem('user');
        delete axios.defaults.headers.common['Authorization'];
      }
    },
    async checkAuth() {
      if (!this.token) return false;
      
      axios.defaults.headers.common['Authorization'] = `Bearer ${this.token}`;
      api.defaults.headers.common['Authorization'] = `Bearer ${this.token}`;
      try {
        const response = await api.get('/me');
        if (response.data.success) {
          this.user = response.data.user;
          localStorage.setItem('user', JSON.stringify(this.user));
          return true;
        }
        return false;
      } catch (err) {
        console.error('Session validation failed:', err);
        // Si el token expiró o es inválido, limpiar sesión
        if (err.response?.status === 401) {
          this.logout();
        }
        return false;
      }
    }
  }
});
