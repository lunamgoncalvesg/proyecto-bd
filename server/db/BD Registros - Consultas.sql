-- a) USO DE OPERADORES (LIKE, IS NULL, NOT IN, IN, BETWEEN)
-- Busca empleados cuyo nombre contenga 'ar'
SELECT * FROM Empleados WHERE nomEmp2 LIKE '%ar%';

-- Muestra los clientes que no tienen segundo apellido
SELECT dniCli, nomCli, apeCli FROM Clientes WHERE apeCli2 IS NULL;

-- Lista oficinas que no tienen trámites asociados
SELECT * FROM Oficinas
WHERE idOf NOT IN (
    SELECT DISTINCT ofi2 FROM Tramites
);

-- Muestra partidas de nacimiento o informes de dominio
SELECT * FROM Tramites
WHERE tipo IN (
    SELECT idTipo FROM TipoTramites
    WHERE nomTipo IN ('Partida de nacimiento', 'Informe de dominio')
);

-- Muestra clientes nacidos entre 1980 y 1990
SELECT * FROM Clientes
WHERE fecNacCli BETWEEN '1980-01-01' AND '1990-12-31';


-- b) FUNCIONES DE FECHAS
-- Calcula la antigüedad en años de empleados activos
SELECT nomEmp, apeEmp, (YEAR(CURDATE()) - YEAR(fecAlta))
FROM Empleados
WHERE fecBaja IS NULL;

-- Muestra la antiguedad en años de empleados que ya se dieron de baja
SELECT nomEmp, apeEmp, (YEAR(fecBaja) - YEAR(fecAlta))
FROM Empleados
WHERE fecBaja IS NOT NULL;

-- Muestra trámites realizados en julio de 2025
SELECT * FROM Tramites
WHERE MONTH(fecha) = 7 AND YEAR(fecha) = 2025;

-- Muestra los clientes que cumplen años en el mes actual
SELECT nomCli, apeCli, fecNacCli
FROM Clientes
WHERE MONTH(fecNacCli) = MONTH(CURDATE());


-- c) AGRUPACIÓN (GROUP BY, HAVING)
-- Calcula edad promedio de clientes por sexo
SELECT sexo, AVG(YEAR(CURDATE()) - YEAR(fecNacCli))
FROM Clientes
GROUP BY sexo;

-- Muestra cuántos trámites hay en cada estado de los trámites con más de 2 registros
SELECT est, COUNT(*)
FROM Tramites
GROUP BY est
HAVING COUNT(*) > 2;


-- d) ORDENAMIENTO (ORDER BY)
-- Lista clientes ordenados por fecha de nacimiento de más viejo a más joven
SELECT nomCli, apeCli, fecNacCli
FROM Clientes
ORDER BY fecNacCli ASC;

-- Lista empleados ordenados por fecha de alta de más reciente a más antigua
SELECT nomEmp, apeEmp, fecAlta
FROM Empleados
ORDER BY fecAlta DESC;


-- e) CAMPOS CALCULADOS/FUNCIONES AGREGADAS
-- Cuenta total de trámites registrados
SELECT COUNT(*) AS total
FROM Tramites;

-- Suma los años trabajados por empleados activos de la oficina 3
SELECT SUM(YEAR(CURDATE()) - YEAR(fecAlta)) 'total anios de trabajo'
FROM Empleados
WHERE ofi = 3 AND fecBaja IS NULL;

-- Muestra la fecha más reciente de los trámites
SELECT MAX(fecha) AS 'fecha más reciente'
FROM Tramites;

-- Muestra la edad más joven entre los clientes
SELECT MIN(YEAR(CURDATE()) - YEAR(fecNacCli)) AS 'más joven'
FROM Clientes;

-- Promedio de edad de los empleados
SELECT AVG(YEAR(CURDATE()) - YEAR(fecNacEmp)) AS promedio
FROM Empleados;


-- f) INNER JOIN
-- Muestra que respuestas se ingresaron a tal trámite de tal tipo
SELECT t.idTra, tt.nomTipo, r.resp, rq.campo
FROM Respuestas r
INNER JOIN Tramites t ON r.tra = t.idTra
INNER JOIN Requisitos rq ON r.campo = rq.idReq
INNER JOIN TipoTramites tt ON rq.tipo2 = tt.idTipo;

-- Lista empleados con su cargo y la localidad de su oficina
SELECT e.nomEmp, e.apeEmp, e.cargo, o.locOf
FROM Empleados e
INNER JOIN Oficinas o ON e.ofi = o.idOf;

-- Muestra trámites junto al tipo y cliente correspondiente
SELECT t.idTra, tt.nomTipo, c.nomCli, c.apeCli, t.fecha, t.est
FROM Tramites t
INNER JOIN TipoTramites tt ON t.tipo = tt.idTipo
INNER JOIN Clientes c ON t.cli = c.dniCli;


-- g) SUBCONSULTAS
-- Muestra oficinas que tienen más de dos empleados
SELECT idOf
FROM Oficinas
WHERE idOf IN (
    SELECT ofi FROM Empleados
    GROUP BY ofi HAVING COUNT(*) > 2
);

-- Muestra el trámite más reciente
SELECT * FROM Tramites
WHERE fecha = (SELECT MAX(fecha) FROM Tramites);

-- Muestra oficinas donde trabaja alguna empleada llamada Paula
SELECT DISTINCT o.idOf, o.locOf
FROM Oficinas o
WHERE idOf IN (
    SELECT ofi FROM Empleados
    WHERE nomEmp = 'Paula'
);

-- Tipos de trámite que aún no tienen trámites asociados
SELECT idTipo, nomTipo FROM TipoTramites
WHERE idTipo NOT IN (SELECT DISTINCT tipo FROM Tramites);

-- Clientes que tienen trámites finalizados
SELECT DISTINCT c.dniCli, c.nomCli
FROM Clientes c
WHERE dniCli IN (
    SELECT cli FROM Tramites WHERE est = 'Finalizado'
);


-- h) CURSORES
-- Cursor que recorre oficinas mostrando cantidad de trámites pendientes
DELIMITER $$
CREATE PROCEDURE ppendientesxofi()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE ofi INT;
    DECLARE loc VARCHAR(50);
    DECLARE cant INT;
    DECLARE cpendientesxofi CURSOR FOR
    SELECT o.idOf, o.locOf, COUNT(t.idTra)
    FROM Oficinas o
    LEFT JOIN Tramites t ON o.idOf = t.ofi2 AND t.est = 'Pendiente'
    GROUP BY o.idOf, o.locOf;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    OPEN cpendientesxofi;
    read_loop: LOOP
    FETCH cpendientesxofi INTO ofi, loc, cant;
    IF done = TRUE THEN
        LEAVE read_loop;
    END IF;
    SELECT CONCAT('La oficina de ', loc, ' tiene ', cant, ' trámites pendientes.');
    END LOOP;
    CLOSE cpendientesxofi;
END $$
DELIMITER ;
CALL ppendientesxofi();

-- Cursor que recorre empleados activos mostrando su cargo y oficina
DELIMITER $$
CREATE PROCEDURE pactivos()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE nom VARCHAR(50);
    DECLARE ape VARCHAR(50);
    DECLARE cargo VARCHAR(20);
    DECLARE loc VARCHAR(50);
    DECLARE cactivos CURSOR FOR
    SELECT e.nomEmp, e.apeEmp, e.cargo, o.locOf
        FROM Empleados e
        JOIN Oficinas o ON e.ofi = o.idOf
        WHERE e.fecBaja IS NULL;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    OPEN cactivos;
    read_loop: LOOP
        FETCH cactivos INTO nom, ape, cargo, loc;
        IF done = TRUE THEN
            LEAVE read_loop;
        END IF;
        SELECT CONCAT(nom, ' ', ape, ' - ', cargo, ' en (', loc, ')');
    END LOOP;
    CLOSE cactivos;
END $$
DELIMITER ;
CALL pactivos();

-- Cursor que recorre tipos de trámite mostrando cantidad de registros por tipo
DELIMITER $$
CREATE PROCEDURE ptraxtipo()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE tipo VARCHAR(100);
    DECLARE cant INT;
    DECLARE ctraxtipo CURSOR FOR
    SELECT tt.nomTipo, COUNT(t.idTra)
        FROM TipoTramites tt
        LEFT JOIN Tramites t ON t.tipo = tt.idTipo
        GROUP BY tt.nomTipo;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    OPEN ctraxtipo;
    read_loop: LOOP
        FETCH ctraxtipo INTO tipo, cant;
        IF done = TRUE THEN
            LEAVE read_loop;
        END IF;
        SELECT CONCAT('Tipo de trámite: ', tipo, ' tiene ', cant, ' registros.');
    END LOOP;
    CLOSE ctraxtipo;
END $$
DELIMITER ;
CALL ptraxtipo();


-- II) PROCEDIMIENTOS ALMACENADOS
-- (Sin parámetros) cantidad de trámites por tipo
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

-- (Sin parámetros) empleados activos
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

-- (Con parámetros) trámites de un cliente según DNI
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

-- (Con parámetros) empleados que trabajan tal oficina
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


-- III) FUNCIONES ALMACENADAS
-- Devuelve el total de trámites
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

-- Devuelve el promedio de edad de clientes
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

-- Devuelve si una persona es mayor o menor de edad
DROP FUNCTION IF EXISTS mayor;
DELIMITER //
CREATE FUNCTION mayor(fecNac DATE)
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    DECLARE edad INT;
    SET edad = (DATEDIFF(CURDATE(), fecNac))/365;
    IF edad >= 18 THEN
        RETURN 'Mayor de edad';
    ELSE
        RETURN 'Menor de edad';
    END IF;
END //
DELIMITER ;
SELECT nomCli, apeCli, fecNacCli, mayor(fecNacCli) FROM Clientes;


-- IV) VISTAS Y SUS USOS
-- Vista de trámites con datos del cliente y tipo de trámite
CREATE VIEW vtramites AS
SELECT t.idTra, tt.nomTipo, c.nomCli, c.apeCli, t.fecha, t.est
FROM Tramites t
JOIN Clientes c ON t.cli = c.dniCli
JOIN TipoTramites tt ON t.tipo = tt.idTipo;
SELECT * FROM vtramites;

-- Vista de empleados activos
CREATE VIEW vempleados AS
SELECT * FROM Empleados WHERE fecBaja IS NULL;
SELECT * FROM vempleados;

-- Vista que muestra cantidad de empleados por oficina
CREATE VIEW vempxofi AS
SELECT o.idOf, o.locOf, COUNT(e.dniEmp) AS cantidad_empleados
FROM Oficinas o
LEFT JOIN Empleados e ON o.idOf = e.ofi
GROUP BY o.idOf;
SELECT * FROM vempxofi;


-- V) CREACIÓN DE USUARIOS Y PRIVILEGIOS
-- Crea usuario tipo root
CREATE USER 'admin'@'localhost' IDENTIFIED BY '1234';
GRANT ALL PRIVILEGES ON Ministerio.* TO 'admin'@'localhost';
FLUSH PRIVILEGES;
SHOW GRANTS FOR 'admin'@localhost;

-- Para empleados que solo pueden agregar, consultar o modificar datos de los trámites y sus respuestas
CREATE USER 'empleados'@'localhost' IDENTIFIED BY '1234';
GRANT SELECT, INSERT, UPDATE ON Ministerio.Tramites TO 'empleado'@'localhost';
GRANT SELECT, INSERT, UPDATE ON Ministerio.Respuestas TO 'empleados'@'localhost';
FLUSH PRIVILEGES;
SHOW GRANTS FOR 'empleados'@localhost;

-- Para hacer tipo censos
CREATE USER 'consultas'@'localhost' IDENTIFIED BY '1234';
GRANT SELECT ON Ministerio.* TO 'consultas'@'localhost';
FLUSH PRIVILEGES;
SHOW GRANTS FOR 'consultas'@localhost;


-- VI) TRIGGERS
-- Impide asignar empleados dados de baja a nuevos trámites
DELIMITER $$
CREATE TRIGGER templeadosno
BEFORE INSERT ON Tramites
FOR EACH ROW
BEGIN
    DECLARE baja DATE;
    SELECT fecBaja INTO baja FROM Empleados WHERE dniEmp = NEW.emp;
    IF baja IS NOT NULL THEN
        SET NEW.emp = NULL;
    END IF;
END $$
DELIMITER ;
INSERT INTO Tramites (idTra, cli, emp, tipo, fecha, est, ofi2)
VALUES (1234, '24735397', '20931884', 2, CURDATE(), 'Pendiente', 1);
SELECT * FROM Tramites WHERE idTra = 1234;

-- Marca el trámite como finalizado cuando se asigna un empleado
DELIMITER $$
CREATE TRIGGER tempasignado
AFTER UPDATE ON Tramites
FOR EACH ROW
BEGIN
    IF OLD.emp IS NULL AND NEW.emp IS NOT NULL THEN
        UPDATE Tramites
        SET est = 'Finalizado'
        WHERE idTra = NEW.idTra;
    END IF;
END $$
DELIMITER ;
SELECT * FROM Tramites WHERE idTra = 1;
UPDATE Tramites SET emp = '30122901' WHERE idTra = 1;
SELECT * FROM Tramites WHERE idTra = 1;
