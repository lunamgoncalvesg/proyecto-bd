"use client";
import { useState } from 'react';
import TramiteForm from './components/TramiteForm';
import Login from './components/Login';
import Register from './components/Register';
import ForgotPassword from './components/ForgotPassword';

function App() {

  const [user, setUser] = useState(null);
  const [screen, setScreen] = useState('login');
  const handleLogout = () => setUser(null);
  
  return (
    <div className="app container">
      {!user ? (
        <>
          {screen == 'login' && <Login setUser={setUser} changeScreen={setScreen} />}
          {screen == 'register' && <Register changeScreen={setScreen} />}
          {screen == 'forgot' && <ForgotPassword changeScreen={setScreen} />}
        </>
      ) : (
        <div className="home container" >
          <h1>Bienvenido {user.nomCli}</h1>
          <button className="small" onClick={handleLogout}>Cerrar sesión</button>
          <hr />
          <TramiteForm user={user} />
        </div>
      )}
    </div>
  );
}

export default App;