import { useState } from 'react';
import axios from 'axios';

const Register = ({ changeScreen }) => {
  const [form, setForm] = useState({
    dniCli: '',
    nomCli: '',
    nomCli2: '',
    apeCli: '',
    apeCli2: '',
    fecNacCli: '',
    sexo: '',
    calleCli: '',
    altCli: '',
    cpCli: '',
    locCli: '',
    telCli: '',
    emailCli: '',
    contCli: ''
  });

  const [message, setMessage] = useState('');

  const handleChange = (e) => setForm({ ...form, [e.target.name]: e.target.value });

  const handleRegister = async () => {
    try {
      await axios.post('http://localhost:3001/api/auth/register', form);
      setMessage('Se creó la cuenta');
    } catch (err) {
      console.error(err);
      setMessage('Error al registrarse');
    }
  };

  return (
    <div className="register container">
      <h1>Registrarse</h1>
      <input name="dniCli" placeholder="DNI" onChange={handleChange} />
      <input name="nomCli" placeholder="Primer nombre" onChange={handleChange} />
      <input name="nomCli2" placeholder="Segundo nombre (opcional)" onChange={handleChange} />
      <input name="apeCli" placeholder="Primer apellido" onChange={handleChange} />
      <input name="apeCli2" placeholder="Segundo apellido (opcional)" onChange={handleChange} />
      <input type="date" name="fecNacCli" onChange={handleChange} />
      <select name="sexo" onChange={handleChange}>
        <option value="">Seleccionar sexo</option>
        <option value="M">Masculino</option>
        <option value="F">Femenino</option>
      </select>
      <input name="calleCli" placeholder="Calle" onChange={handleChange} />
      <input name="altCli" placeholder="Altura" onChange={handleChange} />
      <input name="cpCli" placeholder="Código postal" onChange={handleChange} />
      <input name="locCli" placeholder="Localidad" onChange={handleChange} />
      <input name="telCli" placeholder="Teléfono" onChange={handleChange} />
      <input name="emailCli" placeholder="Correo electrónico" onChange={handleChange} />
      <input name="contCli" type="password" placeholder="Contraseña" onChange={handleChange} />
      <button className="big" onClick={handleRegister}>Crear cuenta</button>
      {message && <h4>{message}</h4>}
      <button className="small" onClick={() => changeScreen('login')}>Volver</button>
    </div>
  );
};

export default Register;