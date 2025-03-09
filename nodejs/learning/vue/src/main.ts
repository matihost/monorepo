import App from './App.vue'
import { createApp } from 'vue'
import { createRouter } from './router'
import { createAuth0 } from '@auth0/auth0-vue'
import { library } from '@fortawesome/fontawesome-svg-core'
import { faLink, faUser, faPowerOff } from '@fortawesome/free-solid-svg-icons'
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'
import hljs from 'highlight.js/lib/core'
import json from 'highlight.js/lib/languages/json'
import hljsVuePlugin from '@highlightjs/vue-plugin'
import 'highlight.js/styles/github.css'

hljs.registerLanguage('json', json)

const app = createApp(App)

library.add(faLink, faUser, faPowerOff)

app.config.globalProperties.$env = import.meta.env.VITE_ENV ?? 'dev'

app
  .use(hljsVuePlugin)
  .use(createRouter(app))
  .use(
    createAuth0({
      domain: import.meta.env.VITE_AUTH0_DOMAIN ?? '',
      clientId: import.meta.env.VITE_AUTH0_CLIENT_ID ?? '',
      authorizationParams: {
        redirect_uri: window.location.origin,
      },
    })
  )
  .component('font-awesome-icon', FontAwesomeIcon)
  .mount('#app')
