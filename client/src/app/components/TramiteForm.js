import React, { useEffect, useState } from 'react';
import axios from 'axios';
import DatePicker from "react-datepicker";
import "react-datepicker/dist/react-datepicker.css";

const TramiteForm = ({ user }) => {
  const [secciones, setSecciones] = useState([]);
  const [tipos, setTipos] = useState([]);
  const [oficinas, setOficinas] = useState([]);
  const [requisitos, setRequisitos] = useState([]);
  const [selectedSeccion, setSelectedSeccion] = useState('');
  const [selectedTipo, setSelectedTipo] = useState('');
  const [selectedOficina, setSelectedOficina] = useState('');
  const [respuestas, setRespuestas] = useState({});
  const [estado, setEstado] = useState('Pendiente');
  const [mensaje, setMensaje] = useState('');
  const [horario, setHorario] = useState([]);
  const [selectedHorario, setSelectedHorario] = useState(null);

  useEffect(() => {
    axios.get('http://localhost:3001/api/tramites/secciones')
      .then(res => setSecciones(res.data))
      .catch(err => console.error(err));
  }, []);

  useEffect(() => {
    if (selectedSeccion) {
      axios.get(`http://localhost:3001/api/tramites/tipotramites/${selectedSeccion}`)
        .then(res => setTipos(res.data))
        .catch(err => console.error(err));
      axios.get(`http://localhost:3001/api/tramites/oficinas/${selectedSeccion}`)
        .then(res => setOficinas(res.data))
        .catch(err => console.error(err));
    } else {
      setTipos([]);
      setOficinas([]);
    }
  }, [selectedSeccion]);

  useEffect(() => {
    if (selectedTipo) {
      axios.get(`http://localhost:3001/api/tramites/requisitos/${selectedTipo}`)
        .then(res => setRequisitos(res.data))
        .catch(err => console.error(err));
    } else setRequisitos([]);
  }, [selectedTipo]);


  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      await axios.post('http://localhost:3001/api/tramites', {
        tipo: selectedTipo,
        cliente: user.dniCli,
        oficina: selectedOficina,
        horario: selectedHorario,
        estado,
        respuestas
      });
      setMensaje('🎀 Trámite registrado con éxito 🎀');
      setSelectedSeccion('');
      setSelectedTipo('');
      setSelectedOficina('');
      setRequisitos([]);
      setRespuestas({});
      setSelectedHorario(null);
    } catch (err) {
      console.error(err);
      setMensaje('Error al registrar el trámite');
    }
  };

  const isWeekday = (date) => {
    const day = date.getDay();
    return day != 0 && day != 6;
  };

  return (
    <div className='tramite container'>
      <h1>Registrar nuevo trámite</h1>
      <form onSubmit={handleSubmit}>
        <select
          value={selectedSeccion}
          onChange={e => {
            setSelectedSeccion(e.target.value);
            setMensaje('');
          }}
          required
        >
          <option value="">Sección</option>
          {secciones.map(sec => (
            <option key={sec.idSec} value={sec.idSec}>{sec.nomSec}</option>
          ))}
        </select>
        <select
          value={selectedTipo}
          onChange={e => setSelectedTipo(e.target.value)}
          required
        >
          <option value="">Tipo de Tramite</option>
          {tipos.map(tipo => (
            <option key={tipo.idTipo} value={tipo.idTipo}>{tipo.nomTipo}</option>
          ))}
        </select>
        <select
          value={selectedOficina}
          onChange={e => setSelectedOficina(e.target.value)}
          required
        >
          <option value="">Oficina</option>
          {oficinas.map(of => (
            <option key={of.idOf} value={of.idOf}>{of.calleOf} {of.altOf}, {of.locOf}</option>
          ))}
        </select>
        <DatePicker
          id="date"
          selected={selectedHorario}
          onChange={setSelectedHorario}
          showTimeSelect
          timeIntervals={30}
          dateFormat="Pp"
          filterDate={isWeekday}
          placeholderText="Fecha y hora"
          minTime={new Date(new Date().setHours(9, 0, 0))}
          maxTime={new Date(new Date().setHours(18, 0, 0))}
        />
        {requisitos.map((req, idx) => (
          <div key={idx}>
            <input className="reqs"
              required
              type="text"
              placeholder={req.campo}
              name={req.idReq}
              value={respuestas[req.idReq] || ''}
              onChange={(e) => setRespuestas({ ...respuestas, [req.idReq]: e.target.value })}
            />
          </div>
        ))}
        <button className="big" type="submit">Confirmar trámite</button>
      </form>
      {mensaje && <h4>{mensaje}</h4>}
    </div>
  );
};

export default TramiteForm;