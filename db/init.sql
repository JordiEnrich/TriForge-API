-- init.sql - TriForge API
-- Script para crear las tablas de la base de datos (MySQL 8).
-- Docker crea la base de datos "triforge" con MYSQL_DATABASE y
-- ejecuta este archivo solo la primera vez que arranca el contenedor.

-- Roles: solo hay dos, admin y usuario
CREATE TABLE roles (
  id     INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(50) NOT NULL UNIQUE
);

-- Usuarios: la contraseña se guarda hasheada, nunca en texto plano.
-- username y email no se pueden repetir
CREATE TABLE usuarios (
  id            INT AUTO_INCREMENT PRIMARY KEY,
  username      VARCHAR(50)  NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  email         VARCHAR(255) NOT NULL UNIQUE,
  rol_id        INT NOT NULL,
  activo        BOOLEAN NOT NULL DEFAULT TRUE,
  creado_en     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (rol_id) REFERENCES roles(id)
);

-- Sesiones: si se borra el usuario se borran también sus sesiones.
-- expira_en lo rellena el servidor al crear la sesión
CREATE TABLE sesiones (
  id         VARCHAR(64) PRIMARY KEY,
  usuario_id INT NOT NULL,
  creada_en  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  expira_en  TIMESTAMP NOT NULL,
  ip         VARCHAR(45),
  FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
);

-- Tareas: el responsable puede estar vacío. Si se borra ese usuario,
-- la tarea se queda sin responsable pero no se borra
CREATE TABLE tareas (
  id              INT AUTO_INCREMENT PRIMARY KEY,
  titulo          VARCHAR(150) NOT NULL,
  descripcion     TEXT,
  estado          ENUM('idea','pendiente','en_curso','en_revision','testear','hecha','bloqueada') NOT NULL DEFAULT 'idea',
  prioridad       ENUM('baja','media','alta') NOT NULL DEFAULT 'media',
  dificultad      ENUM('facil','media','dificil') NOT NULL DEFAULT 'media',
  horas_estimadas DECIMAL(5,2),
  horas_reales    DECIMAL(5,2),
  fecha_inicio    DATE,
  fecha_limite    DATE,
  fecha_fin       DATE,
  responsable_id  INT,
  creada_por      INT NOT NULL,
  creada_en       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  actualizada_en  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (responsable_id) REFERENCES usuarios(id) ON DELETE SET NULL,
  FOREIGN KEY (creada_por)     REFERENCES usuarios(id)
);

-- Los roles tienen que existir antes de registrar a nadie
INSERT INTO roles (nombre) VALUES ('admin'), ('usuario');

-- Admin inicial. Antes de arrancar Docker hay que cambiar
-- PEGAR_AQUI_EL_HASH_BCRYPT por un hash generado con nuestra
-- herramienta de claves y hashes (bcrypt, igual que el login)
INSERT INTO usuarios (username, password_hash, email, rol_id)
VALUES (
  'admin',
  'PEGAR_AQUI_EL_HASH_BCRYPT',
  'admin@triforge.test',
  (SELECT id FROM roles WHERE nombre = 'admin')
);
