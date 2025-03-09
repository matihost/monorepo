import React from 'react'
import logo from '../logo.svg'
import '../App.css'
import MyButton from '../view/Button'
import { useAuth } from 'react-oidc-context'
import { Nav } from '../view/Nav'

function Basic() {
  const auth = useAuth()
  let content
  if (auth.isAuthenticated) {
    content = (
      <div>
        Hello {auth.user?.profile.name} on {process.env.REACT_APP_ENV}
        <MyButton button={{ buttonName: 'Ala' }} />
        <button onClick={() => void auth.removeUser()}>Log out</button>
      </div>
    )
  }
  return (
    <>
      {content}
      <div className="App">
        <header className="App-header">
          <Nav />
          <img src={logo} className="App-logo" alt="logo" />
          <a
            className="App-link"
            href="https://reactjs.org"
            target="_blank"
            rel="noopener noreferrer"
          >
            Learn React
          </a>
          <MyButton button={{ buttonName: 'Ala' }} />
        </header>
      </div>
    </>
  )
}

export default Basic
