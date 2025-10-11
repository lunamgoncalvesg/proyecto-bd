-- No hay tildes porque no las toma, hay cosas googleadas que no usamos en clase.
DROP DATABASE IF EXISTS Ministerio;
CREATE DATABASE Ministerio;
USE Ministerio;

CREATE TABLE Secciones (
  idSec INT AUTO_INCREMENT,
  nomSec VARCHAR(50) UNIQUE NOT NULL,
  descSec VARCHAR(150),
  CONSTRAINT pk_sec PRIMARY KEY (idSec)
);

CREATE TABLE TipoTramites (
  idTipo INT AUTO_INCREMENT,
  nomTipo VARCHAR(100) NOT NULL UNIQUE,
  sec INT NOT NULL,
  descTipo VARCHAR(150),
  CONSTRAINT pk_idTipo PRIMARY KEY (idTipo),
  CONSTRAINT fk_sec FOREIGN KEY (sec) REFERENCES Secciones (idSec)
);

CREATE TABLE Oficinas (
  idOf INT AUTO_INCREMENT,
  calleOf VARCHAR(50) NOT NULL,
  altOf VARCHAR(6) NOT NULL,
  cpOf VARCHAR(5) NOT NULL,
  locOf VARCHAR(50) NOT NULL,
  telOf VARCHAR(12) NOT NULL UNIQUE,
  emailOf VARCHAR(100) NOT NULL UNIQUE,
  piso VARCHAR(2),
  sec2 INT,
  CONSTRAINT pk_idOf PRIMARY KEY (idOf),
  CONSTRAINT fk_sec2 FOREIGN KEY (sec2) REFERENCES Secciones(idSec)
);

CREATE TABLE Clientes (
  dniCli VARCHAR(10),
  nomCli VARCHAR(50) NOT NULL,
  nomCli2 VARCHAR(50),
  apeCli VARCHAR(50) NOT NULL,
  apeCli2 VARCHAR(50),
  fecNacCli DATE NOT NULL,
  sexo VARCHAR(1) NOT NULL,
  calleCli VARCHAR(50) NOT NULL,
  altCli VARCHAR(6) NOT NULL,
  cpCli VARCHAR(5) NOT NULL,
  locCli VARCHAR(50) NOT NULL,
  telCli VARCHAR(12) NOT NULL UNIQUE,
  emailCli VARCHAR(100) NOT NULL UNIQUE,
  contCli VARCHAR(50) NOT NULL,
  CONSTRAINT pk_dniCli PRIMARY KEY (dniCli)
);

CREATE TABLE Empleados (
  dniEmp VARCHAR(10),
  nomEmp VARCHAR(50) NOT NULL,
  nomEmp2 VARCHAR(50),
  apeEmp VARCHAR(50) NOT NULL,
  apeEmp2 VARCHAR(50),
  fecNacEmp DATE NOT NULL,
  fecAlta DATE NOT NULL,
  fecBaja DATE,
  ofi INT NOT NULL,
  cargo VARCHAR(20),
  emailEmp VARCHAR(100) NOT NULL UNIQUE,
  telEmp VARCHAR(12) NOT NULL UNIQUE,
  contEmp VARCHAR(50) NOT NULL,
  CONSTRAINT pk_dniEmp PRIMARY KEY (dniEmp),
  CONSTRAINT fk_ofi FOREIGN KEY (ofi) REFERENCES Oficinas (idOf)
);

CREATE TABLE Tramites (
  idTra INT AUTO_INCREMENT,
  tipo INT NOT NULL,
  cli VARCHAR(10) NOT NULL,
  emp VARCHAR(10),
  ofi2 INT NOT NULL,
  fecha DATE,
  est VARCHAR(50) DEFAULT 'Pendiente',
  CONSTRAINT pk_idTra PRIMARY KEY (idTra),
  CONSTRAINT fk_ofi2 FOREIGN KEY (ofi2) REFERENCES Oficinas (idOf),
  CONSTRAINT fk_emp FOREIGN KEY (emp) REFERENCES Empleados (dniEmp),
  CONSTRAINT fk_cli FOREIGN KEY (cli) REFERENCES Clientes (dniCli),
  CONSTRAINT fk_tipo FOREIGN KEY (tipo) REFERENCES TipoTramites (idTipo)
);

CREATE TABLE Requisitos(
  idReq INT AUTO_INCREMENT,
  campo VARCHAR(100) NOT NULL,
  tipo2 INT NOT NULL,
  CONSTRAINT pk_idReq PRIMARY KEY (idReq),
  CONSTRAINT fk_tipo2 FOREIGN KEY (tipo2) REFERENCES TipoTramites (idTipo)
);

CREATE TABLE Respuestas(
  idRes INT AUTO_INCREMENT,
  tra INT NOT NULL,
  campo INT NOT NULL,
  resp VARCHAR(250) NOT NULL,
  CONSTRAINT pk_idRes PRIMARY KEY (idRes),
  CONSTRAINT fk_tra FOREIGN KEY (tra) REFERENCES Tramites (idTra),
  CONSTRAINT fk_campo FOREIGN KEY (campo) REFERENCES Requisitos (idReq)
);