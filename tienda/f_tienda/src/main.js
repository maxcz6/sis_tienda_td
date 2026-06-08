import { createApp } from 'vue'
import { createPinia } from 'pinia'
import './style.css'
import App from './App.vue'
import router from './router'
import axios from 'axios'
import { useConnectionStore } from './stores/connection'
import api from './services/api'
import { registerSW } from 'virtual:pwa-register'

// Registrar Service Worker para PWA con auto-update
registerSW({
  onNeedRefresh() {
    // El service worker tiene una nueva versión disponible
    if (confirm('Nueva versión disponible. ¿Actualizar ahora?')) {
      window.location.reload()
    }
  },
  onOfflineReady() {
    console.log('InventMax está disponible sin conexión.')
  }
})

const app = createApp(App)
const pinia = createPinia()

app.use(pinia)
app.use(router)

// Configurar token en axios si ya existe en localStorage
const token = localStorage.getItem('token')
if (token) {
  axios.defaults.headers.common['Authorization'] = `Bearer ${token}`
  api.defaults.headers.common['Authorization'] = `Bearer ${token}`
}

// Start connection monitor
const conn = useConnectionStore(pinia)
conn.startMonitor({ heartbeatUrl: '/sanctum/csrf-cookie' })

app.mount('#app')
