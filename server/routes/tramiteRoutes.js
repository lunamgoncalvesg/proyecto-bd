import express from "express";
import {getSecciones, getTipoTramites, getOficinas, getRequisitos, crearTramite} from "../controllers/tramiteController.js";

const router = express.Router();

router.get("/secciones", getSecciones);
router.get("/tipotramites/:idSec", getTipoTramites);
router.get("/oficinas/:idSec", getOficinas);
router.get("/requisitos/:idTipo", getRequisitos);
router.post("/", crearTramite);

export default router;