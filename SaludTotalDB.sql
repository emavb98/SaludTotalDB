CREATE DATABASE SaludTotalDB;

USE SaludTotalDB;

CREATE TABLE Registro_Pacientes (
	
	id_paciente INT IDENTITY (1,1) PRIMARY KEY,
	nombre NVARCHAR (100),
	telefono NVARCHAR (20),
	correo NVARCHAR (100),
	fecha_nacimiento DATE

);

CREATE TABLE Registro_Medicos (
	
	id_medico INT IDENTITY (1,1) PRIMARY KEY,
	nombre NVARCHAR (100),
	especialidad NVARCHAR(100),
	telefono NVARCHAR (20),
	correo NVARCHAR (100)

);

CREATE TABLE Citas_Medicas(
	id_cita INT IDENTITY (1,1) PRIMARY KEY,
	id_paciente INT,
	id_medico INT,
	fecha_cita DATETIME,
	monto DECIMAL (10,2),
	FOREIGN KEY (id_paciente) REFERENCES Registro_Pacientes (id_paciente),
	FOREIGN KEY (id_medico) REFERENCES Registro_Medicos (id_medico) 

);


CREATE TABLE Cobro_Servicios(

	id_factura INT IDENTITY (1,1) PRIMARY KEY,
	id_cita INT,
	monto_cobrado DECIMAL (10,2),
	fecha_factura DATETIME,
	FOREIGN KEY (id_cita) REFERENCES Citas_Medicas (id_cita)
);

CREATE TABLE Auditoria_Precios(

	id_auditoria INT IDENTITY(1,1)PRIMARY KEY,
    Servicio NVARCHAR(100),
    PrecioAnterior DECIMAL(10, 2),
    PrecioNuevo DECIMAL(10, 2),
    FechaCambio DATETIME,
    UsuarioCambio NVARCHAR(100)

);

INSERT INTO Registro_Pacientes (nombre, telefono, correo, fecha_nacimiento) VALUES 

('Carlos Rodríguez', '50622334455', 'carlos@example.com', '1982-03-10'),
('María Gómez', '50677889900', 'maria@example.com', '1995-08-22'),
('Pedro Hernández', '50624567890', 'pedro@example.com', '1970-11-30'),
('Ana Pérez', '50673546789', 'ana@example.com', '1988-07-14'),
('Luis González', '50675893210', 'luis@example.com', '1992-12-01'),
('Verónica Ruiz', '50664678890', 'veronica@example.com', '1987-05-10');

SELECT * FROM Registro_Pacientes

INSERT INTO Registro_Medicos (nombre, especialidad, telefono, correo) VALUES 
('Dr. Ricardo Álvarez', 'Pediatría', '50622445566', 'ricardo@clinicasalud.cr'),
('Dr. Carmen Díaz', 'Dermatología', '50677881122', 'carmen@clinicasalud.cr'),
('Dr. Juan Morales', 'Ginecología', '50625647788', 'juan@clinicasalud.cr'),
('Dr. Andrés Vargas', 'Odontología', '50677112233', 'andres@clinicasalud.cr'),
('Dr. Laura Rodríguez', 'Cardiología', '50678564423', 'laura@clinicasalud.cr'),
('Dr. Javier Fernández', 'Medicina General', '50623456889', 'javier@clinicasalud.cr');

SELECT * FROM Registro_Medicos

INSERT INTO Citas_Medicas (id_paciente, id_medico, fecha_cita, monto) VALUES
(1, 3, '2025-11-10 09:00:00', 120.00),
(2, 1, '2025-11-12 14:00:00', 85.00),
(3, 2, '2025-11-14 11:00:00', 150.00),
(4, 4, '2025-11-15 08:30:00', 100.00),
(5, 5, '2025-11-18 10:30:00', 200.00),
(6, 6, '2025-11-20 16:00:00', 80.00);

SELECT * FROM Citas_Medicas

INSERT INTO Cobro_Servicios (id_cita, monto_cobrado, fecha_factura) VALUES
(1, 120.00, '2025-11-10'),
(2, 85.00, '2025-11-12'),
(3, 150.00, '2025-11-14'),
(4, 100.00, '2025-11-15'),
(5, 200.00, '2025-11-18'),
(6, 80.00, '2025-11-20');

SELECT * FROM Cobro_Servicios

INSERT INTO Auditoria_Precios (Servicio, PrecioAnterior, PrecioNuevo, FechaCambio, UsuarioCambio)
VALUES 
('Consulta Pediatría', 100.00, 120.00, '2025-11-01 10:00:00', 'admin'),
('Consulta Dermatología', 130.00, 150.00, '2025-11-02 12:00:00', 'admin'),
('Consulta Ginecología', 90.00, 110.00, '2025-11-05 14:00:00', 'admin'),
('Consulta Odontología', 95.00, 105.00, '2025-11-06 09:00:00', 'admin'),
('Consulta Cardiología', 150.00, 180.00, '2025-11-07 16:00:00', 'admin'),
('Consulta Medicina General', 80.00, 90.00, '2025-11-08 11:30:00', 'admin');

SELECT * FROM Auditoria_Precios

---- PROCEDIMIENTO

CREATE PROCEDURE ReporteMedicoFacturacion
	@id_medico INT
AS
BEGIN 
	SELECT 
	M.nombre AS Medico,
	M.especialidad,
	P.nombre AS Paciente,
	C.fecha_cita,
	F.monto_cobrado
FROM Cobro_Servicios F
JOIN Citas_Medicas C ON F.id_cita = C.id_cita
JOIN Registro_Medicos M ON C.id_medico = M.id_medico
JOIN Registro_Pacientes P ON C.id_paciente = P.id_paciente
    WHERE C.id_medico = @id_medico;
END;

EXEC ReporteMedicoFacturacion @id_medico = 1;

----- FUNCION

CREATE FUNCTION dbo.fn_ResumenFacturacionPorPaciente (@id_paciente INT)
RETURNS DECIMAL(10, 2)
AS
BEGIN
    DECLARE @TotalFacturado DECIMAL(10, 2);

    -- Calcular el total facturado por el paciente
    SELECT @TotalFacturado = SUM(F.monto_cobrado)
    FROM Cobro_Servicios F
    JOIN Citas_Medicas C ON F.id_cita = C.id_cita
    WHERE C.id_paciente = @id_paciente;

    -- Retornar el total facturado
    RETURN @TotalFacturado;
END;


SELECT dbo.fn_ResumenFacturacionPorPaciente(2) AS TotalFacturado;

--- VISTA

CREATE VIEW Vista_FacturacionGerencial AS
SELECT 
    M.nombre AS Medico,
    M.especialidad AS Especialidad,
    P.nombre AS Paciente,
    C.fecha_cita AS FechaCita,
    F.monto_cobrado AS MontoCobrado
FROM Cobro_Servicios F
JOIN Citas_Medicas C ON F.id_cita = C.id_cita
JOIN Registro_Medicos M ON C.id_medico = M.id_medico
JOIN Registro_Pacientes P ON C.id_paciente = P.id_paciente;


SELECT * FROM Vista_FacturacionGerencial;

---- TRIGGER

CREATE TRIGGER trg_AuditoriaPrecios
ON Cobro_Servicios
AFTER UPDATE
AS
BEGIN
    DECLARE @Servicio NVARCHAR(100),
            @PrecioAnterior DECIMAL(10, 2),
            @PrecioNuevo DECIMAL(10, 2),
            @FechaCambio DATETIME,
            @UsuarioCambio NVARCHAR(100);

    -- Obtener el precio anterior y nuevo de la actualización
    SELECT @PrecioAnterior = i.monto_cobrado, 
           @PrecioNuevo = d.monto_cobrado
    FROM inserted i
    JOIN deleted d ON i.id_factura = d.id_factura;

    -- Obtener el nombre del servicio (nombre del médico y fecha de la cita)
    SELECT @Servicio = M.nombre + ' - ' + CONVERT(NVARCHAR, C.fecha_cita, 120) -- Convertir la fecha a cadena
    FROM inserted i
    JOIN Citas_Medicas C ON i.id_cita = C.id_cita
    JOIN Registro_Medicos M ON C.id_medico = M.id_medico;

    -- Registrar en la tabla de auditoría
    SET @FechaCambio = GETDATE();
    SET @UsuarioCambio = SYSTEM_USER;  -- El nombre del usuario que hizo el cambio

    INSERT INTO Auditoria_Precios (Servicio, PrecioAnterior, PrecioNuevo, FechaCambio, UsuarioCambio)
    VALUES (@Servicio, @PrecioAnterior, @PrecioNuevo, @FechaCambio, @UsuarioCambio);
END;

UPDATE Cobro_Servicios
SET monto_cobrado = 160.00
WHERE id_factura = 1;

SELECT * FROM Auditoria_Precios

DROP TRIGGER trg_AuditoriaPrecios;


----- CTE

WITH IngresosPorMedico AS (
    SELECT 
        M.nombre AS Medico,
        M.especialidad AS Especialidad,
        SUM(F.monto_cobrado) AS TotalFacturado
    FROM Cobro_Servicios F
    JOIN Citas_Medicas C ON F.id_cita = C.id_cita
    JOIN Registro_Medicos M ON C.id_medico = M.id_medico
    GROUP BY M.nombre, M.especialidad
)
SELECT 
    Medico, 
    Especialidad, 
    TotalFacturado
FROM IngresosPorMedico
WHERE TotalFacturado > 100.00
ORDER BY TotalFacturado DESC;


