import express from "express";
import cors from "cors";
import authRoutes from "./routes/authRoutes.js";
import tramiteRoutes from "./routes/tramiteRoutes.js";

const app = express();

app.use(cors());
app.use(express.json());

app.use("/api/auth", authRoutes);
app.use("/api/tramites", tramiteRoutes);

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Servidor andando en ${PORT}`));