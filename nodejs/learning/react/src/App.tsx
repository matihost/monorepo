import React from "react";
import { useAuth, hasAuthParams } from "react-oidc-context";
import MyButton from './view/Button';
import { Nav } from "./view/Nav";

function App() {
    const auth = useAuth();

    const [hasTriedSignin, setHasTriedSignin] = React.useState(false);

    // automatically sign-in
    React.useEffect(() => {
        if (!hasAuthParams() &&
            !auth.isAuthenticated && !auth.activeNavigator && !auth.isLoading &&
            !hasTriedSignin
        ) {
            auth.signinRedirect();
            setHasTriedSignin(true);
        }
    }, [auth, hasTriedSignin]);

    React.useEffect(() => {
        // the `return` is important - addAccessTokenExpiring() returns a cleanup function
        return auth.events.addAccessTokenExpiring(() => {
            alert("You're about to be signed out due to inactivity. Press continue to stay signed in.")
            auth.signinSilent();
        })
    }, [auth.events, auth.signinSilent]);

    switch (auth.activeNavigator) {
        case "signinSilent":
            return <div>Signing you in...</div>;
        case "signoutRedirect":
            return <div>Signing you out...</div>;
    }

    if (auth.isLoading) {
        return <div>Loading...</div>;
    }

    if (auth.error) {
        return <div>Oops... {auth.error.message}</div>;
    }

    if (auth.isAuthenticated) {
        return (
        <div>
            Hello {auth.user?.profile.name}{" "}
            <Nav />
            <MyButton button={{ buttonName: "Ala" }}/>
            <button onClick={() => void auth.removeUser()}>Log out</button>
        </div>
        );
    }

    return <button onClick={() => void auth.signinRedirect()}>Log in</button>;
}

export default App;
