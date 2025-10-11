import { useState } from 'react';
import axios from 'axios';

const ForgotPassword = ({ changeScreen }) => {
  const [email, setEmail] = useState('');
  const [newPassword, setNewPassword] = useState('');
  const [message, setMessage] = useState('');

  const handlePasswordChange = async () => {
    try {
      await axios.post('http://localhost:3001/api/auth/reset-password', {email, newPassword});
      setMessage('Se cambió la contraseña');
    } catch (err) {
      setMessage('Error al actualizar la contraseña');
      console.error(err);
    }
  };

  return (
    <div className="forgot container">
      <h1>Restablecer contraseña</h1>
      <input
        placeholder="Correo electrónico"
        value={email}
        onChange={(e) => setEmail(e.target.value)}
      />
      <input
        placeholder="Nueva contraseña"
        type="password"
        value={newPassword}
        onChange={(e) => setNewPassword(e.target.value)}
      />
      <button className="big" onClick={handlePasswordChange}>Actualizar contraseña</button>
      {message && <h4>{message}</h4>}
      <button className="small" onClick={() => changeScreen('login')}>Volver</button>
    </div>
  );
};

export default ForgotPassword;