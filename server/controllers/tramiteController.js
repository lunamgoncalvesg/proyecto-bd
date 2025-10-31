import pool from "../db/db.js";

export const getSecciones = async (req, res) => {
    await pool.query("SELECT * FROM secciones", (err, results) => {
    if (err) return res.status(500).json({ message: "Error al obtener secciones" });
    res.json(results);
    });
};

export const getTipoTramites = async (req, res) => {
    const { idSec } = req.params;
    await pool.query("SELECT * FROM tipotramites WHERE sec = ?", [idSec], (err, results) => {
    if (err) return res.status(500).json({ message: "Error al obtener tipos" });
    res.json(results);
    });
};

export const getOficinas = async (req, res) => {
    const { idSec } = req.params;
    await pool.query("SELECT * FROM oficinas WHERE sec2 = ?", [idSec], (err, results) => {
    if (err) return res.status(500).json({ message: "Error al obtener oficinas" });
    res.json(results);
    });
};

export const getRequisitos = async (req, res) => {
    const { idTipo } = req.params;
    await pool.query("SELECT * FROM requisitos WHERE tipo2 = ?", [idTipo], (err, results) => {
    if (err) return res.status(500).json({ message: "Error al obtener requisitos" });
    res.json(results);
    });
};

export const crearTramite = async (req, res) => {
    const { tipo, cliente, oficina, horario, estado, respuestas } = req.body;
    const query = `INSERT INTO tramites (tipo, cli, ofi2, fecha, est) VALUES (?, ?, ?, ?, ?)`;
    await pool.query(query, [tipo, cliente, oficina, horario, estado], async (err, result) => {
        if (err) {
            console.error("Error al registrar trámite:", err);
            return res.status(500).json({ message: "Error al registrar trámite" });
        }
        const tramiteId = result.insertId;
        const values = Object.keys(respuestas).map((key) => [tramiteId, key, respuestas[key]]);
        const queryRespuestas = `INSERT INTO respuestas (tra, campo, resp) VALUES ?`;
        await pool.query(queryRespuestas, [values], (err2) => {
        if (err2) {
            console.error("Error al subir las respuestas:", err2);
            return res.status(500).json({ message: "Error al subir las respuestas" });
        } return res.json({ message: "Trámite y respuestas registrados" });
        });
    });
};