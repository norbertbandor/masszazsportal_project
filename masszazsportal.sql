-- Az adatbázis karakterkészlete mindenhol utf8mb4
CREATE DATABASE IF NOT EXISTS masszazsportal
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_hungarian_ci;

USE masszazsportal;

-- Felhasználói szerepkörök (enumként rögzítve a fő táblákban)
-- Szükséges masszázstípusokat tartalmazó táblák
CREATE TABLE masszazstipus (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nev VARCHAR(32) NOT NULL UNIQUE
);

INSERT INTO masszazstipus (nev) VALUES
  ('Svédmasszázs'),
  ('Frissítő masszázs'),
  ('Gyógymasszázs'),
  ('Sportmasszázs'),
  ('Talpmasszázs'),
  ('Nyirokmasszázs'),
  ('Cellulit masszázs'),
  ('Lávaköves masszázs'),
  ('Thai masszázs'),
  ('Shiatsu masszázs'),
  ('Relaxáló masszázs'),
  ('Kismama masszázs'),
  ('Reflexzóna masszázs'),
  ('Köpölyözés'),
  ('Mélyszöveti masszázs'),
  ('Csokoládé masszázs'),
  ('Aromaolajos masszázs'),
  ('Bambusz masszázs'),
  ('Triggerpont masszázs'),
  ('Stresszoldó masszázs'),
  ('Egyéb');

-- Szakma típusok
CREATE TABLE szakmatipus (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nev VARCHAR(32) NOT NULL UNIQUE
);

INSERT INTO szakmatipus (nev) VALUES
  ('masszőr'),
  ('csontkovács'),
  ('reflexológus'),
  ('egyéb');

-- Szakember tábla
CREATE TABLE szakember (
  id INT AUTO_INCREMENT PRIMARY KEY,
  teljes_nev VARCHAR(128) NOT NULL,
  email VARCHAR(128) NOT NULL UNIQUE,
  jelszo_hash VARCHAR(255) NOT NULL,
  nem ENUM('férfi', 'nő') NOT NULL,
  profilkep VARCHAR(255),
  szakmatipus_id INT NOT NULL,
  szakmatipus_egyeb VARCHAR(12),
  bemutatkozas VARCHAR(500),
  telephely_e BOOLEAN DEFAULT FALSE,
  hazhozmegy_e BOOLEAN DEFAULT FALSE,
  telephely_iranyitoszam VARCHAR(8),
  telephely_varos VARCHAR(64),
  telephely_utca VARCHAR(64),
  telephely_hazszam VARCHAR(16),
  telephely_emelet_ajto VARCHAR(16),
  hazhoz_varosok VARCHAR(256),
  hazhoz_dij INT,
  telefonszam VARCHAR(32),
  statusz ENUM('uj', 'elutasitott', 'aktiv') DEFAULT 'uj',
  letrehozas DATETIME DEFAULT CURRENT_TIMESTAMP,
  modositas DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  email_megerositve BOOLEAN DEFAULT FALSE,
  szakmai_igazolas VARCHAR(255),
  szakmai_igazolas_feltoltve DATETIME,
  szakmai_igazolas_torolve DATETIME,
  FOREIGN KEY (szakmatipus_id) REFERENCES szakmatipus(id)
);

-- Szakember – masszázstípusok kapcsolótábla (többes kapcsolat)
CREATE TABLE szakember_masszazstipus (
  szakember_id INT NOT NULL,
  masszazstipus_id INT NOT NULL,
  egyeb_masszazstipus VARCHAR(12),
  PRIMARY KEY (szakember_id, masszazstipus_id),
  FOREIGN KEY (szakember_id) REFERENCES szakember(id) ON DELETE CASCADE,
  FOREIGN KEY (masszazstipus_id) REFERENCES masszazstipus(id) ON DELETE CASCADE
);

-- Vendég tábla
CREATE TABLE vendeg (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nev VARCHAR(128) NOT NULL,
  email VARCHAR(128) NOT NULL UNIQUE,
  jelszo_hash VARCHAR(255) NOT NULL,
  nem ENUM('férfi', 'nő') NOT NULL,
  email_megerositve BOOLEAN DEFAULT FALSE,
  letrehozas DATETIME DEFAULT CURRENT_TIMESTAMP,
  modositas DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Adminisztrátor tábla
CREATE TABLE admin (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nev VARCHAR(128) NOT NULL,
  email VARCHAR(128) NOT NULL UNIQUE,
  jelszo_hash VARCHAR(255) NOT NULL,
  letrehozas DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Szakemberek értékelése (csak vendég értékelhet)
CREATE TABLE ertekeles (
  id INT AUTO_INCREMENT PRIMARY KEY,
  szakember_id INT NOT NULL,
  vendeg_id INT NOT NULL,
  pontszam INT NOT NULL CHECK (pontszam BETWEEN 1 AND 5),
  szoveg VARCHAR(100),
  letrehozas DATETIME DEFAULT CURRENT_TIMESTAMP,
  statusz ENUM('uj', 'aktiv', 'elutasitott') DEFAULT 'uj',
  FOREIGN KEY (szakember_id) REFERENCES szakember(id) ON DELETE CASCADE,
  FOREIGN KEY (vendeg_id) REFERENCES vendeg(id) ON DELETE CASCADE
);

-- Blogbejegyzések
CREATE TABLE blog (
  id INT AUTO_INCREMENT PRIMARY KEY,
  cim VARCHAR(255) NOT NULL,
  szoveg TEXT NOT NULL,
  szerzo_id INT,
  letrehozas DATETIME DEFAULT CURRENT_TIMESTAMP,
  modositas DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  aktiv BOOLEAN DEFAULT TRUE,
  FOREIGN KEY (szerzo_id) REFERENCES admin(id)
);

-- Elfelejtett jelszó token
CREATE TABLE visszaallitas (
  id INT AUTO_INCREMENT PRIMARY KEY,
  felhasznalo_email VARCHAR(128) NOT NULL,
  token VARCHAR(128) NOT NULL,
  lejar DATETIME NOT NULL,
  felhasznalva BOOLEAN DEFAULT FALSE
);

-- E-mail megerősítő token
CREATE TABLE email_megerosites (
  id INT AUTO_INCREMENT PRIMARY KEY,
  felhasznalo_email VARCHAR(128) NOT NULL,
  token VARCHAR(128) NOT NULL,
  letrehozas DATETIME DEFAULT CURRENT_TIMESTAMP,
  felhasznalva BOOLEAN DEFAULT FALSE
);

-- Általános beállítások, statikus tartalom (ÁSZF, impresszum) – opcionális
CREATE TABLE statikus_oldal (
  id INT AUTO_INCREMENT PRIMARY KEY,
  tipus ENUM('aszf', 'impresszum') NOT NULL UNIQUE,
  tartalom TEXT NOT NULL,
  modositas DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Indexek a fontos keresési mezőkre
CREATE INDEX idx_szakember_statusz ON szakember (statusz);
CREATE INDEX idx_szakember_telephely_varos ON szakember (telephely_varos);
CREATE INDEX idx_szakember_hazhoz_varosok ON szakember (hazhoz_varosok);

-- Adatvédelmi okokból a szakmai igazolás fájl csak addig van eltárolva, amíg az admin jóvá nem hagyja.
