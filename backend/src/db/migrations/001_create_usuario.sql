CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE IF NOT EXISTS usuario (
    id_usuario UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    matricula VARCHAR(20) UNIQUE NOT NULL,
    nombre_completo VARCHAR(150) NOT NULL,
    correo VARCHAR(150) UNIQUE NOT NULL,
    contrasena VARCHAR(255) NOT NULL,
    carrera VARCHAR(100),
    semestre INTEGER,
    fecha_registro TIMESTAMP NOT NULL DEFAULT NOW(),
    foto_perfil VARCHAR(255),
    reputacion DECIMAL(3,2) DEFAULT 0.00
);