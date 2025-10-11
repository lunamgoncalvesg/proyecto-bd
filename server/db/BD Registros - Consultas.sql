--a) Uso de operadores (LIKE, IS NULL, NOT IN, IN, BETWEEN).
SELECT * FROM Empleados WHERE nomEmp2 LIKE '%ar%';


SELECT dniCli, nomCli, apeCli FROM Clientes WHERE apeCli2 IS NULL;


SELECT * FROM Oficinas
WHERE idOf NOT IN (
    SELECT DISTINCT ofi2 FROM Tramites
);


SELECT * FROM Tramites
WHERE tipo IN (
    SELECT idTipo FROM TipoTramites
    WHERE nomTipo IN ('Partida de nacimiento', 'Informe de dominio')
);


SELECT * FROM Clientes
WHERE fecNacCli BETWEEN '1980-01-01' AND '1990-12-31';


--b) Funciones de fechas.
SELECT nomEmp, apeEmp, (YEAR(CURDATE()) - YEAR(fecAlta)) AS antiguedad
FROM Empleados
WHERE fecBaja IS NULL;


SELECT nomEmp, apeEmp, (YEAR(fecBaja) - YEAR(fecAlta)) AS 'años trabajados'
FROM Empleados
WHERE fecBaja IS NOT NULL;


SELECT * FROM Tramites
WHERE MONTH(fecha) = 7 AND YEAR(fecha) = 2025;


SELECT nomCli, apeCli, fecNacCli
FROM Clientes
WHERE MONTH(fecNacCli) = MONTH(CURDATE());


--c) Agrupación (Group By, Having).
SELECT sexo, AVG(YEAR(CURDATE()) - YEAR(fecNacCli)) AS 'edad promedio'
FROM Clientes
GROUP BY sexo;


SELECT est, COUNT(*) AS cantidad
FROM Tramites
GROUP BY est
HAVING COUNT(*) > 2;


--d) Ordenamiento (Order By).
SELECT nomCli, apeCli, fecNacCli
FROM Clientes
ORDER BY fecNacCli ASC;


SELECT nomEmp, apeEmp, fecAlta
FROM Empleados
ORDER BY fecAlta DESC;


--e) Campos calculados ó funciones agregadas de dominio (Count, Sum, Max, Min, Avg).
SELECT COUNT(*) AS total
FROM Tramites;


SELECT SUM(YEAR(CURDATE()) - YEAR(fecAlta)) AS 'total anios de trabajo'
FROM Empleados
WHERE ofi = 3 AND fecBaja IS NULL;


SELECT MAX(fecha) AS 'fecha más reciente'
FROM Tramites;


SELECT MIN(YEAR(CURDATE()) - YEAR(fecNacCli)) AS 'edad mínima'
FROM Clientes;


SELECT AVG(YEAR(CURDATE()) - YEAR(fecNacEmp)) AS promedio
FROM Empleados;


--f) Inner join.
SELECT t.idTra, tt.nomTipo, r.resp, rq.campo
FROM Respuestas r
INNER JOIN Tramites t ON r.tra = t.idTra
INNER JOIN Requisitos rq ON r.campo = rq.idReq
INNER JOIN TipoTramites tt ON rq.tipo2 = tt.idTipo;


--agregar consulta

--g) Subconsultas.
SELECT idOf
FROM Oficinas
WHERE idOf IN (
    SELECT ofi FROM Empleados
    GROUP BY ofi HAVING COUNT(*) > 2
);


SELECT * FROM Tramites
WHERE fecha = (SELECT MAX(fecha) FROM Tramites);


SELECT DISTINCT o.idOf, o.locOf
FROM Oficinas o
WHERE idOf IN (
    SELECT ofi FROM Empleados
    WHERE nomEmp = 'Paula'
);


SELECT idTipo, nomTipo FROM TipoTramites
WHERE idTipo NOT IN (SELECT DISTINCT tipo FROM Tramites);

SELECT DISTINCT c.dniCli, c.nomCli
FROM Clientes c
WHERE dniCli IN (
    SELECT cli FROM Tramites WHERE est = 'Finalizado'
);


--h) Seleccionar y justificar adecuadamente el uso de:
--I) Cursores.
No visto todavía.

--II) Procedimientos Almacenados con y sin parámetros.
DROP PROCEDURE IF EXISTS tramitesxtipo;
DELIMITER //
CREATE PROCEDURE tramitesxtipo()
BEGIN
    SELECT TT.nomTipo AS Tipo, COUNT(T.idTra) AS Cantidad
    FROM Tramites T
    JOIN TipoTramites TT ON T.tipo = TT.idTipo
    GROUP BY TT.nomTipo
    ORDER BY Cantidad DESC;
END //
DELIMITER ;
CALL tramitesxtipo();


DROP PROCEDURE IF EXISTS empactuales;
DELIMITER //
CREATE PROCEDURE empactuales()
BEGIN
    SELECT dniEmp, nomEmp, apeEmp, fecAlta
    FROM Empleados
    WHERE fecBaja IS NULL;
END //
DELIMITER ;
CALL empactuales();


DROP PROCEDURE IF EXISTS tramitescliente;
DELIMITER //
CREATE PROCEDURE tramitescliente(IN dni VARCHAR(10))
BEGIN
    SELECT T.idTra, TT.nomTipo, T.fecha, T.est
    FROM Tramites T
    JOIN TipoTramites TT ON T.tipo = TT.idTipo
    WHERE T.cli = dni;
END //
DELIMITER ;
CALL tramitescliente('37844622');


DROP PROCEDURE IF EXISTS empleadosxlocalidad;
DELIMITER //
CREATE PROCEDURE empleadosxlocalidad(IN localidad VARCHAR(50))
BEGIN
    SELECT E.dniEmp, E.nomEmp, O.locOf
    FROM Empleados E
    JOIN Oficinas O ON E.ofi = O.idOf
    WHERE O.locOf = localidad;
END //
DELIMITER ;
CALL empleadosxlocalidad('Devoto');


--III) Funciones Almacenadas.
DROP FUNCTION IF EXISTS total;
DELIMITER //
CREATE FUNCTION total()
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE total INT;
    SELECT COUNT(*) INTO total FROM Tramites;
    RETURN total;
END //
DELIMITER ;
SELECT total() 'Total de trámites';


DROP FUNCTION IF EXISTS promedio;
DELIMITER //
CREATE FUNCTION promedio()
RETURNS FLOAT
DETERMINISTIC
BEGIN
    DECLARE promedio FLOAT;
    SELECT AVG(YEAR(CURDATE()) - YEAR(fecNacCli)) INTO promedio FROM Clientes;
    RETURN promedio;
END //
DELIMITER ;
SELECT promedio() AS 'Edad promedio de clientes';


DROP FUNCTION IF EXISTS mayor;
DELIMITER //
CREATE FUNCTION mayor(fecNac DATE)
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    DECLARE edad INT;
    SET edad = DATEDIFF(CURDATE(), fecNac);
    IF edad >= 18 THEN
    RETURN 'Mayor de edad';
    ELSE
    RETURN 'Menor de edad';
    END IF;
END //
DELIMITER ;
SELECT nomCli, apeCli, fecNacCli, mayor(fecNacCli)
FROM Clientes;


--IV) Vistas y sus posibles usos.
CREATE VIEW vtramites AS
SELECT t.idTra, tt.nomTipo, c.nomCli, c.apeCli, t.fecha, t.est
FROM Tramites t
JOIN Clientes c ON t.cli = c.dniCli
JOIN TipoTramites tt ON t.tipo = tt.idTipo;
--Vista de trámites.

CREATE VIEW vempleados AS
SELECT * FROM Empleados WHERE fecBaja IS NULL;
--Vista de empleados actuales.

CREATE VIEW vempxofi AS
SELECT o.idOf, o.locOf, COUNT(e.dniEmp) AS cantidad_empleados
FROM Oficinas o
LEFT JOIN Empleados e ON o.idOf = e.ofi
GROUP BY o.idOf;
--Vista de empleados por oficina.