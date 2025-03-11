import { NavLink } from "react-router";

export function Nav() {
  return (
    <nav>
      <NavLink
        to="/"
        end>
        Home - with auto sign in via OIDC
      </NavLink>
      <NavLink
        to="/basic"
        end>
        Basic React Page
      </NavLink>
      <NavLink to="/auth">Page with optional logon via OIDC</NavLink>
    </nav>
  );
}
