import Vue from "vue";
import App from "./App.vue";
import router from "./router";

// OAuth START
// Import the Auth0 configuration

// Import the plugin here
import { Auth0Plugin } from "./auth";

// Install the authentication plugin here
Vue.use(Auth0Plugin, {
  domain: process.env.VUE_APP_AUTH0_DOMAIN,
  clientId: process.env.VUE_APP_AUTH0_CLIENT_ID,
  onRedirectCallback: (appState) => {
    router.push(appState && appState.targetUrl ? appState.targetUrl : window.location.pathname);
  },
});
// OAuth END

Vue.config.productionTip = false;
Vue.prototype.$env = process.env.VUE_APP_ENV ?? "dev";

new Vue({
  router,
  render: (h) => h(App),
}).$mount("#app");
