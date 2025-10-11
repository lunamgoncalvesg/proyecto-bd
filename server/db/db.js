import mysql from "mysql";

const db = mysql.createConnection({
    host: process.env.DB_HOST || "localhost",
    user: process.env.DB_USER || "root",
    password: process.env.DB_PASSWORD || "",
    database: process.env.DB_NAME || "ministerio"
});

db.connect((err) => {
    if (err) {
    console.error("Error al conectar con la base de datos:", err);
    } else {
    console.log("Conectado a la base de datos Ministerio");
    }
});

export default db;