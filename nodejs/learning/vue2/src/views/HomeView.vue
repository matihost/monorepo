<template>
  <div class="home">
    <img
      alt="Vue logo"
      src="../assets/logo.png" />
    <HelloWorld :msg="'Welcome to Your Vue.js App in mode: ' + environment" />

    <!-- Check that the SDK client is not currently loading before accessing is methods -->
    <div v-if="!$auth.loading">
      <!-- show login when not authenticated -->
      <button
        v-if="!$auth.isAuthenticated"
        @click="login">
        Log in
      </button>
      <!-- show logout when authenticated -->
      <button
        v-if="$auth.isAuthenticated"
        @click="logout">
        Log out
      </button>

      <div v-if="$auth.isAuthenticated">
        <div>
          <img :src="$auth.user.picture" />
          <h2>{{ $auth.user.name }}</h2>
          <p>{{ $auth.user.email }}</p>
        </div>

        <div>
          <pre>{{ JSON.stringify($auth.user, null, 2) }}</pre>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
  // @ is an alias to /src
  import HelloWorld from "@/components/HelloWorld.vue";

  export default {
    name: "HomeView",
    components: {
      HelloWorld,
    },
    computed: {
      environment: function () {
        return this.$env;
      },
    },
    methods: {
      // Log the user in
      login() {
        this.$auth.loginWithRedirect();
      },
      // Log the user out
      logout() {
        this.$auth.logout({
          logoutParams: {
            returnTo: window.location.origin,
          },
        });
      },
    },
  };
</script>
