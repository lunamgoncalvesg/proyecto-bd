import db from "../db/db.js";

export const getSecciones = (req, res) => {
    db.query("SELECT * FROM secciones", (err, results) => {
    if (err) return res.status(500).json({ message: "Error al obtener secciones" });
    res.json(results);
    });
};

export const getTipoTramites = (req, res) => {
    const { idSec } = req.params;
    db.query("SELECT * FROM tipotramites WHERE sec = ?", [idSec], (err, results) => {
    if (err) return res.status(500).json({ message: "Error al obtener tipos" });
    res.json(results);
    });
};

export const getOficinas = (req, res) => {
    const { idSec } = req.params;
    db.query("SELECT * FROM oficinas WHERE sec2 = ?", [idSec], (err, results) => {
    if (err) return res.status(500).json({ message: "Error al obtener oficinas" });
    res.json(results);
    });
};

export const getRequisitos = (req, res) => {
    const { idTipo } = req.params;
    db.query("SELECT * FROM requisitos WHERE tipo2 = ?", [idTipo], (err, results) => {
    if (err) return res.status(500).json({ message: "Error al obtener requisitos" });
    res.json(results);
    });
};

export const crearTramite = (req, res) => {
    const { tipo, cliente, oficina, horario, estado, respuestas } = req.body;
    const query = `INSERT INTO tramites (tipo, cli, ofi2, fecha, est) VALUES (?, ?, ?, ?, ?)`;
    db.query(query, [tipo, cliente, oficina, horario, estado], (err, result) => {
        if (err) {
            console.error("Error al registrar trámite:", err);
            return res.status(500).json({ message: "Error al registrar trámite" });
        }
        const tramiteId = result.insertId;
        const values = Object.keys(respuestas).map((key) => [tramiteId, key, respuestas[key]]);
        const queryRespuestas = `INSERT INTO respuestas (tra, campo, resp) VALUES ?`;
        db.query(queryRespuestas, [values], (err2) => {
        if (err2) {
            console.error("Error al subir las respuestas:", err2);
            return res.status(500).json({ message: "Error al subir las respuestas" });
        } return res.json({ message: "Trámite y respuestas registrados" });
        });
    });
};