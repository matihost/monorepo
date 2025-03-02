import React from 'react';
import ReactDOM from 'react-dom/client';
import './index.css';
import App from './App';
import { AuthProvider } from "react-oidc-context";
import { User, WebStorageStateStore } from "oidc-client-ts";
import { BrowserRouter, Routes, Route } from "react-router";
import AuthNoAutoLogin from './routes/AuthNoAutoLogin';
import Basic from './routes/Basic';

const onSigninCallback = (_user: User | void): void => {
    window.history.replaceState(
        {},
        document.title,
        window.location.pathname
    )
}

const oidcConfig = {
  authority: process.env.REACT_APP_OIDC_ISSUER,
  client_id: process.env.REACT_APP_OIDC_CLIENT_ID,
  redirect_uri: window.location.origin,
  scope: "openid profile email",
  // mandatory cleanup
  onSigninCallback : onSigninCallback,
  // silently login when tab is closed
  userStore: new WebStorageStateStore({ store: window.localStorage }),
  // ...
};
const root = ReactDOM.createRoot(
  document.getElementById('root') as HTMLElement
);
root.render(
  <React.StrictMode>
   <AuthProvider {...oidcConfig}>
   <BrowserRouter>
   <Routes>
      <Route path="/" element={<App />} />
      <Route path="/auth" element={<AuthNoAutoLogin />} />
      <Route path="/basic" element={<Basic />} />
    </Routes>
  </BrowserRouter>
  </AuthProvider>
  </React.StrictMode>
);
