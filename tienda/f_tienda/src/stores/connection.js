import { defineStore } from 'pinia'
import axios from 'axios'

export const useConnectionStore = defineStore('connection', {
  state: () => ({
    online: navigator.onLine,
    lastChecked: null,
    flushing: false
  }),
  actions: {
    setOnline(v) {
      this.online = !!v;
      this.lastChecked = Date.now();
    },
    async startMonitor({heartbeatUrl} = {}){
      // Basic online/offline monitoring: navigator + heartbeat
      window.addEventListener('online', () => { this.setOnline(true); this.flushQueue(); });
      window.addEventListener('offline', () => { this.setOnline(false); });

      // Derive sensible default heartbeat URL if none provided or if provided as relative path
      // Prefer VITE_API_URL (may include /api). We want the API root (no /api) to call /sanctum/csrf-cookie
      try{
        const envApi = import.meta.env.VITE_API_URL || '';
        const origin = (() => {
          if (envApi) {
            // remove trailing /api if present
            return envApi.replace(/\/api\/?$/, '').replace(/\/$/, '');
          }
          // fallback to dev backend on same host port 8000
          return `${location.protocol}//${location.hostname}:8000`;
        })();

        if (!heartbeatUrl) {
          heartbeatUrl = `${origin}/sanctum/csrf-cookie`;
        } else if (heartbeatUrl.startsWith('/')) {
          heartbeatUrl = `${origin}${heartbeatUrl}`;
        } else if (!/^https?:\/\//.test(heartbeatUrl)) {
          // relative-ish: prefix with origin
          heartbeatUrl = `${origin}/${heartbeatUrl}`;
        }
      }catch(e){
        // ignore and keep provided heartbeatUrl
      }

      // Periodic heartbeat to backend to ensure API reachable
      const check = async () => {
        try {
          // try a HEAD to reduce payload; fallback to GET
          await axios.head(heartbeatUrl, { timeout: 3000 });
          this.setOnline(true);
        } catch (err) {
          // network down or server unreachable
          this.setOnline(false);
        }
      };

      // run immediately and then every 10s
      await check();
      setInterval(check, 10000);

      // attempt flush when becoming online
      this.flushQueue();
    },
    async flushQueue(){
      // Replay queued requests stored in localStorage
      if (this.flushing) return;
      if (!this.online) return;
      const key = 'offlineQueue';
      let queue = [];
      try { queue = JSON.parse(localStorage.getItem(key) || '[]'); } catch(e){ queue = []; }
      if (!queue.length) return;
      this.flushing = true;
      try{
        for (const req of queue){
          try{
            await axios({
              method: req.method,
              url: req.url,
              data: req.data,
              headers: req.headers || {}
            });
            // success -> remove from queue later
            // we'll filter successful ones afterwards
            req._ok = true;
          }catch(e){
            // stop processing on first failure to preserve order
            break;
          }
        }
      }finally{
        // keep only not-ok items
        const remaining = queue.filter(r => !r._ok);
        localStorage.setItem(key, JSON.stringify(remaining));
        this.flushing = false;
      }
    }
  }
})
