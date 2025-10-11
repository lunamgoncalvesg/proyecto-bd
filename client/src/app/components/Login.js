import { useState } from 'react';
import axios from 'axios';

const Login = ({ setUser, changeScreen }) => {
    const [account, setAccount] = useState('');
    const [password, setPassword] = useState('');

    const handleLogin = async () => {
        try {
            const res = await axios.post('http://localhost:3001/api/auth/login', {account, password});
            setUser(res.data);
        } catch (err) {
            alert('Usuario o contraseña incorrectos');
            console.error(err);
        }
    };

    return (
        <div className="login container">
            <h1>Iniciar sesión</h1>
            <input
                placeholder="Correo electrónico o teléfono"
                value={account}
                onChange={(e) => setAccount(e.target.value)}
            />
            <input
                placeholder="Contraseña"
                type="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
            />
            <button className="big" onClick={handleLogin}>Entrar</button>
            <div className="links container">
            <button className="small" onClick={() => changeScreen('forgot')}>Olvidé mi contraseña</button>
            <button className="small" onClick={() => changeScreen('register')}>Registrarse</button>
            </div>
        </div>
    );
};

export default Login;