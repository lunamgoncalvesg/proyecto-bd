import db from "../db/db.js";

export const login = (req, res) => {
  const { account, password } = req.body;
  const query = `SELECT * FROM clientes WHERE (emailCli = ? OR telCli = ?) AND contCli = ?`;
  db.query(query, [account, account, password], (err, results) => {
    if (err) {
      console.error("Error en login:", err);
      return res.status(500).json({ message: "Error en el servidor" });
    }
    if (results.length == 0) {
      return res.status(401).json({ message: "Usuario o contraseña incorrectos" });
    }
    return res.json(results[0]);
  });
};

export const register = (req, res) => {
  const data = req.body;
  const query = `INSERT INTO clientes (dniCli, nomCli, nomCli2, apeCli, apeCli2, fecNacCli, sexo, calleCli, altCli, cpCli, locCli, telCli, emailCli, contCli) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`;
  const values = [
    data.dniCli,
    data.nomCli,
    data.nomCli2 || null,
    data.apeCli,
    data.apeCli2 || null,
    data.fecNacCli,
    data.sexo,
    data.calleCli,
    data.altCli,
    data.cpCli,
    data.locCli,
    data.telCli,
    data.emailCli,
    data.contCli,
  ];
  db.query(query, values, (err) => {
    if (err) {
      console.error("Error al registrar:", err);
      return res.status(500).json({ message: "Error al registrar el cliente" });
    } return res.json({ message: "Se registró correctamente" });
  });
};

export const resetPassword = (req, res) => {
  const { email, newPassword } = req.body;
  if (!email || !newPassword) return res.status(400).json({ message: "Faltan datos." });
  const checkQuery = "SELECT * FROM clientes WHERE emailCli = ?";
  db.query(checkQuery, [email], (err, results) => {
    if (err) {
      console.error("Error al buscar usuario:", err);
      return res.status(500).json({ message: "Error en el servidor" });
    }
    if (results.length == 0) return res.status(404).json({ message: "No existe un usuario con ese correo" });
    const updateQuery = "UPDATE clientes SET contCli = ? WHERE emailCli = ?";
    db.query(updateQuery, [newPassword, email], (err2) => {
      if (err2) {
        console.error("Error al actualizar contraseña:", err2);
        return res.status(500).json({ message: "Error al actualizar la contraseña" });
      } return res.json({ message: "Contraseña actualizada" });
    });
  });
};