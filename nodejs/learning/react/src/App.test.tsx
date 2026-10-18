import { render, screen } from "@testing-library/react";
import { MemoryRouter } from "react-router";
import { vi } from "vitest";
import App from "./App";

const auth = {
  isAuthenticated: false,
  isLoading: false,
  activeNavigator: undefined,
  error: undefined,
  user: undefined,
  signinRedirect: vi.fn(),
  signinSilent: vi.fn(),
  removeUser: vi.fn(),
  events: { addAccessTokenExpiring: vi.fn(() => () => {}) },
};

vi.mock("react-oidc-context", () => ({
  useAuth: () => auth,
  hasAuthParams: () => false,
}));

function renderApp() {
  return render(
    <MemoryRouter>
      <App />
    </MemoryRouter>,
  );
}

afterEach(() => {
  vi.clearAllMocks();
  Object.assign(auth, { isAuthenticated: false, isLoading: false, user: undefined, error: undefined });
});

test("redirects anonymous user to sign in", () => {
  renderApp();
  expect(auth.signinRedirect).toHaveBeenCalledTimes(1);
});

test("shows loading state", () => {
  auth.isLoading = true;
  renderApp();
  expect(screen.getByText("Loading...")).toBeInTheDocument();
});

test("shows greeting and navigation for authenticated user", () => {
  Object.assign(auth, { isAuthenticated: true, user: { profile: { name: "Ala" } } });
  renderApp();
  expect(screen.getByText(/Hello Ala/)).toBeInTheDocument();
  expect(screen.getByRole("link", { name: /Basic React Page/ })).toBeInTheDocument();
  expect(screen.getByRole("button", { name: "Log out" })).toBeInTheDocument();
});
