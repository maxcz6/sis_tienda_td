import axios from 'axios'
import { useConnectionStore } from '../stores/connection'

const api = axios.create({ baseURL: import.meta.env.VITE_API_URL || '' })

// Queue failed POST/PUT/DELETE requests when offline
const enqueue = (req) => {
  const key = 'offlineQueue'
  try{
    const q = JSON.parse(localStorage.getItem(key) || '[]')
    q.push(req)
    localStorage.setItem(key, JSON.stringify(q))
  }catch(e){ /* ignore */ }
}

api.interceptors.request.use((cfg)=>{
  // attach token if present
  const token = localStorage.getItem('token')
  if (token) cfg.headers = cfg.headers || {}, cfg.headers.Authorization = `Bearer ${token}`
  return cfg
})

api.interceptors.response.use((r)=>r, async (err)=>{
  const conn = useConnectionStore()
  // if network error or 5xx and method is mutating -> enqueue
  const cfg = err.config || {}
  const method = (cfg.method || '').toLowerCase()
  const isMutating = ['post','put','patch','delete'].includes(method)
  if ((!err.response && !navigator.onLine) || (isMutating && err.response && err.response.status >= 500)){
    // enqueue
    if (isMutating){
      enqueue({ method: cfg.method, url: cfg.url, data: cfg.data, headers: cfg.headers })
    }
    conn.setOnline(false)
    return Promise.reject(err)
  }
  return Promise.reject(err)
})

export default api
