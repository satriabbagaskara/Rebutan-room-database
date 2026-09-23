-- ============================================================
-- DATABASE CREATION & SETUP
-- System: Rebutan.room (Campus Room Reservation Management)
-- ============================================================

CREATE DATABASE IF NOT EXISTS rebutan_room;
USE rebutan_room;

-- Disable Foreign Key checks for clean reset
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS persetujuan;
DROP TABLE IF EXISTS detailPeminjaman;
DROP TABLE IF EXISTS peminjaman;
DROP TABLE IF EXISTS detailAdminGdg;
DROP TABLE IF EXISTS detailAdminFkt;
DROP TABLE IF EXISTS roleAdmin;
DROP TABLE IF EXISTS staff;
DROP TABLE IF EXISTS dosen;
DROP TABLE IF EXISTS mahasiswa;
DROP TABLE IF EXISTS pengguna;
DROP TABLE IF EXISTS detailFasilitas;
DROP TABLE IF EXISTS ruangan;
DROP TABLE IF EXISTS fasilitas;
DROP TABLE IF EXISTS gedungKhusus;
DROP TABLE IF EXISTS gedungUmum;
DROP TABLE IF EXISTS gedung;
DROP TABLE IF EXISTS fakultas;
DROP TABLE IF EXISTS cabang;
DROP TABLE IF EXISTS kampus;

SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================
-- 1. ENTITAS UTAMA (Kampus, Cabang, Fakultas)
-- ============================================================

CREATE TABLE kampus (
    idKampus INT,
    namaKampus VARCHAR(100) NOT NULL,
    PRIMARY KEY (idKampus)
);

CREATE TABLE cabang (
    idCabang INT,
    idKampus INT,
    namaCabang VARCHAR(100) NOT NULL,
    alamatCabang TEXT NOT NULL,
    kontak VARCHAR(50),
    PRIMARY KEY (idCabang),
    FOREIGN KEY (idKampus) REFERENCES kampus(idKampus)
);

CREATE TABLE fakultas (
    idFakultas INT,
    namaFakultas VARCHAR(100) NOT NULL,
    PRIMARY KEY (idFakultas)
);

-- ============================================================
-- 2. ENTITAS GEDUNG & RUANGAN
-- ============================================================

CREATE TABLE gedung (
    idGedung INT,
    idCabang INT,
    kodeGedung VARCHAR(20) NOT NULL,
    namaGedung VARCHAR(100) NOT NULL,
    jumlahLantai INT NOT NULL,
    idFakultas INT NULL, -- NULL jika gedung bersifat umum
    PRIMARY KEY (idGedung),
    FOREIGN KEY (idCabang) REFERENCES cabang(idCabang),
    FOREIGN KEY (idFakultas) REFERENCES fakultas(idFakultas)
);

CREATE TABLE gedungUmum (
    idGedung INT,
    PRIMARY KEY (idGedung),
    FOREIGN KEY (idGedung) REFERENCES gedung(idGedung)
);

CREATE TABLE gedungKhusus (
    idGedung INT,
    idFakultas INT NOT NULL,
    PRIMARY KEY (idGedung),
    FOREIGN KEY (idGedung) REFERENCES gedung(idGedung),
    FOREIGN KEY (idFakultas) REFERENCES fakultas(idFakultas)
);

CREATE TABLE fasilitas (
    idFasilitas INT,
    namaFasilitas VARCHAR(100) NOT NULL,
    PRIMARY KEY (idFasilitas)
);

CREATE TABLE ruangan (
    idRuangan INT NOT NULL,
    idGedung INT NOT NULL,
    lokasiLantai INT NOT NULL,
    kategoriRuangan VARCHAR(50) NOT NULL,
    namaRuangan VARCHAR(100) NOT NULL,
    nomorRuangan VARCHAR(20) NOT NULL,
    kapasitas INT NOT NULL,
    statusRuangan VARCHAR(50) NOT NULL,
    PRIMARY KEY (idRuangan),
    FOREIGN KEY (idGedung) REFERENCES gedung(idGedung)
);

CREATE TABLE detailFasilitas (
    idFasilitas INT,
    idRuangan INT,
    jumlahFasilitas INT NOT NULL,
    PRIMARY KEY (idFasilitas, idRuangan),
    FOREIGN KEY (idFasilitas) REFERENCES fasilitas(idFasilitas),
    FOREIGN KEY (idRuangan) REFERENCES ruangan(idRuangan)
);

-- ============================================================
-- 3. ENTITAS PENGGUNA & PERAN (User, Mahasiswa, Dosen, Staff)
-- ============================================================

CREATE TABLE pengguna (
    idPengguna INT,
    idCabang INT NOT NULL,
    idFakultas INT NOT NULL,
    rolePengguna TEXT NOT NULL,
    namaLengkap VARCHAR(100) NOT NULL,
    namaPengguna VARCHAR(100) NOT NULL,
    nomorPengguna VARCHAR(20),
    PRIMARY KEY (idPengguna),
    FOREIGN KEY (idCabang) REFERENCES cabang(idCabang),
    FOREIGN KEY (idFakultas) REFERENCES fakultas(idFakultas)
);

CREATE TABLE mahasiswa (
    idPengguna INT,
    NIM VARCHAR(20) NOT NULL,
    PRIMARY KEY (idPengguna),
    FOREIGN KEY (idPengguna) REFERENCES pengguna(idPengguna)
);

CREATE TABLE dosen (
    idPengguna INT,
    NIP VARCHAR(20) NOT NULL,
    PRIMARY KEY (idPengguna),
    FOREIGN KEY (idPengguna) REFERENCES pengguna(idPengguna)
);

CREATE TABLE staff (
    idPengguna INT,
    NIK VARCHAR(20) NOT NULL,
    bidangStaff VARCHAR(100),
    PRIMARY KEY (idPengguna),
    FOREIGN KEY (idPengguna) REFERENCES pengguna(idPengguna)
);

-- ============================================================
-- 4. ENTITAS ADMIN & HAK AKSES
-- ============================================================

CREATE TABLE roleAdmin (
    idAdmin INT,
    idPengguna INT NOT NULL,
    idGedung INT NULL,
    idFakultas INT NULL,
    namaRole TEXT NOT NULL,
    levelAkses INT NOT NULL,
    PRIMARY KEY (idAdmin),
    FOREIGN KEY (idPengguna) REFERENCES pengguna(idPengguna),
    FOREIGN KEY (idGedung) REFERENCES gedung(idGedung),
    FOREIGN KEY (idFakultas) REFERENCES fakultas(idFakultas)
);

CREATE TABLE detailAdminFkt (
    idFakultas INT NOT NULL,
    idAdmin INT NOT NULL,
    PRIMARY KEY (idFakultas, idAdmin),
    FOREIGN KEY (idFakultas) REFERENCES fakultas(idFakultas),
    FOREIGN KEY (idAdmin) REFERENCES roleAdmin(idAdmin)
);

CREATE TABLE detailAdminGdg (
    idGedung INT NOT NULL,
    idAdmin INT NOT NULL,
    PRIMARY KEY (idGedung, idAdmin),
    FOREIGN KEY (idGedung) REFERENCES gedung(idGedung),
    FOREIGN KEY (idAdmin) REFERENCES roleAdmin(idAdmin)
);

-- ============================================================
-- 5. ENTITAS TRANSAKSI (Peminjaman & Persetujuan)
-- ============================================================

CREATE TABLE peminjaman (
    idPeminjaman INT,
    idPengguna INT NOT NULL,
    tujuanPeminjaman TEXT NOT NULL,
    waktuPengajuan DATETIME NOT NULL,
    suratPeminjaman VARCHAR(225) NOT NULL,
    statusPeminjaman TEXT NOT NULL,
    PRIMARY KEY (idPeminjaman),
    FOREIGN KEY (idPengguna) REFERENCES pengguna(idPengguna)
);

CREATE TABLE detailPeminjaman (
    idDetailPeminjaman INT,
    idPeminjaman INT NOT NULL,
    idRuangan INT NOT NULL,
    tanggalPeminjaman DATE NOT NULL,
    waktuPeminjaman TIME NOT NULL,
    waktuSelesai TIME NOT NULL,
    tanggalSelesai DATE NOT NULL,
    PRIMARY KEY (idDetailPeminjaman),
    FOREIGN KEY (idPeminjaman) REFERENCES peminjaman(idPeminjaman),
    FOREIGN KEY (idRuangan) REFERENCES ruangan(idRuangan)
);

CREATE TABLE persetujuan (
    idPersetujuan INT,
    idDetailPeminjaman INT NOT NULL,
    idAdmin INT NOT NULL,
    waktuPersetujuan DATETIME NOT NULL,
    statusPersetujuan VARCHAR(50) NOT NULL,
    PRIMARY KEY (idPersetujuan),
    FOREIGN KEY (idDetailPeminjaman) REFERENCES detailPeminjaman(idDetailPeminjaman),
    FOREIGN KEY (idAdmin) REFERENCES roleAdmin(idAdmin)
);
