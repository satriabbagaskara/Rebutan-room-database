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

-- ============================================================
-- DATA SEEDING (DML / INSERT INTO)
-- System: Rebutan.room
-- ============================================================

USE rebutan_room;

-- ------------------------------------------------------------
-- 1. DATA KAMPUS
-- ------------------------------------------------------------
INSERT INTO kampus (idKampus, namaKampus) VALUES 
(1, 'Universitas Nusantara Bangsa'), 
(2, 'Institut Teknologi Maju'), 
(3, 'Universitas Harapan Indonesia'), 
(4, 'Universitas Digital Nusantara'), 
(5, 'Universitas Sejahtera Mandiri'), 
(6, 'Institut Sains dan Teknologi Nusantara'), 
(7, 'Universitas Karya Bangsa'), 
(8, 'Universitas Cendekia Utama'), 
(9, 'Politeknik Inovasi Indonesia'), 
(10, 'Universitas Mitra Akademika');

-- ------------------------------------------------------------
-- 2. DATA FAKULTAS
-- ------------------------------------------------------------
INSERT INTO fakultas (idFakultas, namaFakultas) VALUES 
(1, 'Fakultas Teknik'), (2, 'Fakultas Ilmu Komputer'), (3, 'Fakultas Ekonomi dan Bisnis'), 
(4, 'Fakultas Hukum'), (5, 'Fakultas Kedokteran'), (6, 'Fakultas Farmasi'), 
(7, 'Fakultas Psikologi'), (8, 'Fakultas Ilmu Sosial dan Politik'), (9, 'Fakultas Pertanian'), 
(10, 'Fakultas Peternakan'), (11, 'Fakultas Kehutanan'), (12, 'Fakultas Kelautan dan Perikanan'), 
(13, 'Fakultas Matematika dan IPA'), (14, 'Fakultas Pendidikan'), (15, 'Fakultas Bahasa dan Sastra'), 
(16, 'Fakultas Seni dan Desain'), (17, 'Fakultas Arsitektur'), (18, 'Fakultas Kedokteran Gigi'), 
(19, 'Fakultas Keperawatan'), (20, 'Fakultas Kesehatan Masyarakat'), (21, 'Fakultas Biologi'), 
(22, 'Fakultas Kimia'), (23, 'Fakultas Fisika'), (24, 'Fakultas Geografi'), 
(25, 'Fakultas Teknik Sipil'), (26, 'Fakultas Teknik Elektro'), (27, 'Fakultas Teknik Mesin'), 
(28, 'Fakultas Teknik Industri'), (29, 'Fakultas Teknik Kimia'), (30, 'Fakultas Teknik Informatika'), 
(31, 'Fakultas Sistem Informasi'), (32, 'Fakultas Manajemen'), (33, 'Fakultas Akuntansi'), 
(34, 'Fakultas Ilmu Komunikasi'), (35, 'Fakultas Hubungan Internasional'), (36, 'Fakultas Administrasi Bisnis'), 
(37, 'Fakultas Ilmu Gizi'), (38, 'Fakultas Veteriner'), (39, 'Fakultas Teknik Lingkungan'), 
(40, 'Fakultas Perencanaan Wilayah dan Kota'), (41, 'Fakultas Teknik Geologi'), (42, 'Fakultas Kriminologi'), 
(43, 'Fakultas Ilmu Perpustakaan'), (44, 'Fakultas Sosiologi'), (45, 'Fakultas Antropologi'), 
(46, 'Fakultas Teologi'), (47, 'Fakultas Filsafat'), (48, 'Fakultas Olahraga'), 
(49, 'Fakultas Pariwisata'), (50, 'Fakultas Perhotelan'), (51, 'Fakultas Teknik Perkapalan'), 
(52, 'Fakultas Teknik Penerbangan'), (53, 'Fakultas Kebidanan'), (54, 'Fakultas Rekam Medis'), 
(55, 'Fakultas Radiologi'), (56, 'Fakultas Analis Kesehatan'), (57, 'Fakultas Fisioterapi'), 
(58, 'Fakultas Terapi Wicara'), (59, 'Fakultas Ortotik Prostetik'), (60, 'Fakultas Keselamatan dan Kesehatan Kerja'), 
(61, 'Fakultas Administrasi Negara'), (62, 'Fakultas Ilmu Politik'), (63, 'Fakultas Statistika'), 
(64, 'Fakultas Aktuaria'), (65, 'Fakultas Astronomi'), (66, 'Fakultas Meteorologi'), 
(67, 'Fakultas Oseanografi'), (68, 'Fakultas Teknik Biomedis'), (69, 'Fakultas Nanoteknologi'), 
(70, 'Fakultas Teknik Nuklir'), (71, 'Fakultas Keuangan dan Perbankan'), (72, 'Fakultas Bisnis Digital'), 
(73, 'Fakultas Keamanan Siber'), (74, 'Fakultas Kecerdasan Buatan'), (75, 'Fakultas Data Sains'), 
(76, 'Fakultas Robotika'), (77, 'Fakultas Internet of Things'), (78, 'Fakultas Blockchain dan Kripto'), 
(79, 'Fakultas Animasi dan Multimedia'), (80, 'Fakultas Desain Komunikasi Visual'), (81, 'Fakultas Teknik Tekstil'), 
(82, 'Fakultas Teknologi Pangan'), (83, 'Fakultas Teknologi Hasil Pertanian'), (84, 'Fakultas Agribisnis'), 
(85, 'Fakultas Agroteknologi'), (86, 'Fakultas Ilmu Tanah'), (87, 'Fakultas Entomologi'), 
(88, 'Fakultas Hortikultura'), (89, 'Fakultas Teknik Pertambangan'), (90, 'Fakultas Teknik Perminyakan'), 
(91, 'Fakultas Teknik Metalurgi'), (92, 'Fakultas Keramik'), (93, 'Fakultas Optometri'), 
(94, 'Fakultas Farmasi Klinis'), (95, 'Fakultas Teknologi Farmasi'), (96, 'Fakultas Pendidikan Dokter Spesialis'), 
(97, 'Fakultas Pendidikan Profesi Apoteker'), (98, 'Fakultas Sains Terapan'), (99, 'Fakultas Vokasi'), 
(100, 'Fakultas Pascasarjana');

-- ------------------------------------------------------------
-- 3. DATA CABANG KAMPUS
-- ------------------------------------------------------------
INSERT INTO cabang (idCabang, idKampus, namaCabang, alamatCabang, kontak) VALUES 
(1, 1, 'Kampus Utama Bandung', 'Jl. Dipatiukur No.1, Bandung', '022-1234001'),
(2, 1, 'Kampus Cimahi', 'Jl. Industri No. 10, Cimahi', '022-1234002'),
(3, 1, 'Kampus Sumedang', 'Jl. Prabu Gajah Agung No.5, Sumedang', '0261-1234003'),
(4, 1, 'Kampus Garut', 'Jl. Ciledug No.12, Garut', '0262-1234004'),
(5, 1, 'Kampus Tasikmalaya', 'Jl. HZ Mustofa No.9, Tasikmalaya', '0265-1234005'),
(6, 1, 'Kampus Majalengka', 'Jl. KH Abdul Halim No.3, Majalengka', '0233-1234006'),
(7, 1, 'Kampus Cianjur', 'Jl. Ir. H. Juanda No.7, Cianjur', '0263-1234007'),
(8, 1, 'Kampus Purwakarta', 'Jl. Veteran No.21, Purwakarta', '0264-1234008'),
(9, 1, 'Kampus Karawang', 'Jl. HS. Ronggowaluyo No. 15, Karawang', '0267-1234009'),
(10, 1, 'Kampus Subang', 'Jl. Ahmad Yani No.6, Subang', '0260-1234010'),
(11, 2, 'Kampus Utama Jakarta', 'Jl. Sudirman No. 100, Jakarta', '021-2345001'),
(12, 2, 'Kampus Depok', 'Jl. Margonda Raya No.55, Depok', '021-2345002'),
(13, 2, 'Kampus Bekasi', 'Jl. Ahmad Yani No.30, Bekasi', '021-2345003'),
(14, 2, 'Kampus Tangerang', 'Jl. Jenderal Sudirman No.45, Tangerang', '021-2345004'),
(15, 2, 'Kampus Bogor', 'Jl. Pajajaran No.22, Bogor', '0251-2345005'),
(16, 3, 'Kampus Utama Surabaya', 'Jl. Pemuda No.77, Surabaya', '031-3456001'),
(17, 3, 'Kampus Malang', 'Jl. Veteran No.8, Malang', '0341-3456002'),
(18, 3, 'Kampus Sidoarjo', 'Jl. Pahlawan No. 11, Sidoarjo', '031-3456003'),
(19, 3, 'Kampus Mojokerto', 'Jl. Gajah Mada No.20, Mojokerto', '0321-3456004'),
(20, 3, 'Kampus Pasuruan', 'Jl. Untung Suropati No. 14, Pasuruan', '0343-3456005'),
(21, 4, 'Kampus Utama Yogyakarta', 'Jl. Kaliurang Km.5, Yogyakarta', '0274-4567001'),
(22, 4, 'Kampus Sleman', 'Jl. Magelang No.36, Sleman', '0274-4567002'),
(23, 4, 'Kampus Bantul', 'Jl. Jenderal Sudirman No. 10, Bantul', '0274-4567003'),
(24, 4, 'Kampus Gunung Kidul', 'Jl. Brigjen Katamso No.2, Wonosari', '0274-4567004'),
(25, 4, 'Kampus Kulonprogo', 'Jl. Tentara Pelajar No.5, Wates', '0274-4567005'),
(26, 5, 'Kampus Utama Semarang', 'Jl. Prof.Sudarto SH No. 13, Semarang', '024-5678001'),
(27, 5, 'Kampus Salatiga', 'Jl. Diponegoro No. 18, Salatiga', '0298-5678002'),
(28, 5, 'Kampus Magelang', 'Jl. Jenderal Ahmad Yani No.9, Magelang', '0293-5678003'),
(29, 5, 'Kampus Pekalongan', 'Jl. Sriwijaya No.3, Pekalongan', '0285-5678004'),
(30, 5, 'Kampus Kudus', 'Jl. PB Sudirman No. 19, Kudus', '0291-5678005'),
(31, 6, 'Kampus Utama Medan', 'Jl. Universitas No.5, Medan', '061-6789001'),
(32, 6, 'Kampus Binjai', 'Jl. Soekarno Hatta No. 12, Binjai', '061-6789002'),
(33, 6, 'Kampus Deli Serdang', 'Jl. Kolam No. 1, Medan Estate', '061-6789003'),
(34, 6, 'Kampus Langkat', 'Jl. Imam Bonjol No. 7, Stabat', '0620-6789004'),
(35, 6, 'Kampus Simalungun', 'Jl. Jenderal Sudirman No. 4, Pematangsiantar', '0622-6789005'),
(36, 7, 'Kampus Utama Makassar', 'Jl. Perintis Kemerdekaan Km.10, Makassar', '0411-7890001'),
(37, 7, 'Kampus Gowa', 'Jl. Poros Malino No.8, Sungguminasa', '0411-7890002'),
(38, 7, 'Kampus Maros', 'Jl. Poros Makassar-Maros No. 15, Maros', '0411-7890003'),
(39, 7, 'Kampus Palopo', 'Jl. Andi Djemma No. 14, Palopo', '0471-7890004'),
(40, 7, 'Kampus Pare-Pare', 'Jl. Bau Massepe No.57, Pare-Pare', '0421-7890005'),
(41, 8, 'Kampus Utama Padang', 'Jl. Limau Manis No.1, Padang', '0751-8901001'),
(42, 8, 'Kampus Payakumbuh', 'Jl. Sudirman No.5, Payakumbuh', '0752-8901002'),
(43, 8, 'Kampus Bukittinggi', 'Jl. Gurun Aua No.7, Bukittinggi', '0752-8901003'),
(44, 8, 'Kampus Pariaman', 'Jl. Syekh Burhanuddin No.2, Pariaman', '0751-8901004'),
(45, 8, 'Kampus Solok', 'Jl. Siri Tabing No. 10, Solok', '0755-8901005'),
(46, 9, 'Kampus Utama Palembang', 'Jl. Srijaya Negara No.1, Palembang', '0711-9012001'),
(47, 9, 'Kampus Prabumulih', 'Jl. Sudirman No.9, Prabumulih', '0713-9012002'),
(48, 9, 'Kampus Lubuklinggau', 'Jl. Yos Sudarso No.3, Lubuklinggau', '0733-9012003'),
(49, 9, 'Kampus Lahat', 'Jl. Mayor Ruslan No.7, Lahat', '0731-9012004'),
(50, 9, 'Kampus Muara Enim', 'Jl. Kolonel Wahid Udin No.12, Muara Enim', '0734-9012005'),
(51, 10, 'Kampus Utama Pontianak', 'Jl. Ahmad Yani No.28, Pontianak', '0561-0123001'),
(52, 10, 'Kampus Singkawang', 'Jl. Firdaus No.6, Singkawang', '0562-0123002'),
(53, 10, 'Kampus Sambas', 'Jl. Pembangunan No.2, Sambas', '0562-0123003'),
(54, 10, 'Kampus Ketapang', 'Jl. S. Parman No.11, Ketapang', '0534-0123004'),
(55, 10, 'Kampus Sanggau', 'Jl. Jenderal Sudirman No.13, Sanggau', '0564-0123005'),
(56, 1, 'Kampus Cirebon', 'Jl. Brigjend Darsono No.5, Cirebon', '0231-1234056'),
(57, 1, 'Kampus Sukabumi', 'Jl. Surya Kencana No.3, Sukabumi', '0266-1234057'),
(58, 2, 'Kampus Cilegon', 'Jl. SA Tirtayasa No. 1, Cilegon', '0254-2345058'),
(59, 2, 'Kampus Serang', 'Jl. Raya Jakarta KM.4, Serang', '0254-2345059'),
(60, 3, 'Kampus Kediri', 'Jl. Veteran No.17, Kediri', '0354-3456060'),
(61, 3, 'Kampus Blitar', 'Jl. Merdeka No.12, Blitar', '0342-3456061'),
(62, 3, 'Kampus Jember', 'Jl. Kalimantan No.37, Jember', '0331-3456062'),
(63, 3, 'Kampus Banyuwangi', 'Jl. Adi Sucipto No.26, Banyuwangi', '0333-3456063'),
(64, 3, 'Kampus Madiun', 'Jl. Serayu No.16, Madiun', '0351-3456064'),
(65, 4, 'Kampus Solo', 'Jl. Brigjen Katamso No.100, Solo', '0271-4567065'),
(66, 4, 'Kampus Klaten', 'Jl. Merbabu No.5, Klaten', '0272-4567066'),
(67, 4, 'Kampus Purworejo', 'Jl. Kutoarjo No.3, Purworejo', '0275-4567067'),
(68, 5, 'Kampus Tegal', 'Jl. Pemuda No. 10, Tegal', '0283-5678068'),
(69, 5, 'Kampus Cilacap', 'Jl. Gatot Subroto No.8, Cilacap', '0282-5678069'),
(70, 5, 'Kampus Purwokerto', 'Jl. HR Bunyamin No. 1, Purwokerto', '0281-5678070'),
(71, 6, 'Kampus Tebing Tinggi', 'Jl. Sutomo No.4, Tebing Tinggi', '0621-6789071'),
(72, 6, 'Kampus Kisaran', 'Jl. Cokroaminoto No.6, Kisaran', '0623-6789072'),
(73, 7, 'Kampus Bone', 'Jl. A.Mannappiang No.12, Watampone', '0481-7890073'),
(74, 7, 'Kampus Wajo', 'Jl. Veteran No.5, Sengkang', '0485-7890074'),
(75, 8, 'Kampus Sijunjung', 'Jl. Prof.M. Yamin No.3, Muaro Sijunjung', '0754-8901075'),
(76, 9, 'Kampus Baturaja', 'Jl. Raya Baturaja No.7, Baturaja', '0735-9012076'),
(77, 9, 'Kampus Indralaya', 'Jl. Raya Palembang-Prabumulih KM.32', '0711-9012077'),
(78, 10, 'Kampus Mempawah', 'Jl. Gusti Hamzah No.5, Mempawah', '0561-0123078'),
(79, 1, 'Kampus Indramayu', 'Jl. Pemuda No.8, Indramayu', '0234-1234079'),
(80, 2, 'Kampus Lebak', 'Jl. Multatuli No.11, Rangkasbitung', '0252-2345080'),
(81, 3, 'Kampus Probolinggo', 'Jl. Dr. Moh.Saleh No.6, Probolinggo', '0335-3456081'),
(82, 4, 'Kampus Wonogiri', 'Jl. Raya Wonogiri-Solo No.4', '0273-4567082'),
(83, 5, 'Kampus Rembang', 'Jl. Pemuda No.3, Rembang', '0295-5678083'),
(84, 6, 'Kampus Sibolga', 'Jl. Pane No.2, Sibolga', '0631-6789084'),
(85, 7, 'Kampus Barru', 'Jl. Sultan Hasanuddin No.9, Barru', '0427-7890085'),
(86, 8, 'Kampus Padang Panjang', 'Jl. Sutan Syahrir No.4, Padang Panjang', '0752-8901086'),
(87, 9, 'Kampus Pagaralam', 'Jl. Merdeka No.6, Pagaralam', '0730-9012087'),
(88, 10, 'Kampus Bengkayang', 'Jl. Guna Baru No.3, Bengkayang', '0562-0123088'),
(89, 1, 'Kampus Bandung Timur', 'Jl. AH Nasution No. 105, Bandung', '022-1234089'),
(90, 1, 'Kampus Bandung Barat', 'Jl. Padalarang No.20, Bandung Barat', '022-1234090'),
(91, 2, 'Kampus Jakarta Barat', 'Jl. Daan Mogot No.60, Jakarta Barat', '021-2345091'),
(92, 2, 'Kampus Jakarta Selatan', 'Jl. TB Simatupang No.33, Jakarta Selatan', '021-2345092'),
(93, 3, 'Kampus Surabaya Timur', 'Jl. Gunung Anyar No.7, Surabaya', '031-3456093'),
(94, 4, 'Kampus Yogyakarta Timur', 'Jl. Solo No. 12, Yogyakarta', '0274-4567094'),
(95, 5, 'Kampus Semarang Selatan', 'Jl. Pleburan No.5, Semarang', '024-5678095'),
(96, 6, 'Kampus Medan Selatan', 'Jl. Setiabudi No.9, Medan', '061-6789096'),
(97, 7, 'Kampus Makassar Timur', 'Jl. Hertasning No. 14, Makassar', '0411-7890097'),
(98, 8, 'Kampus Padang Barat', 'Jl. Rasuna Said No.6, Padang', '0751-8901098'),
(99, 9, 'Kampus Palembang Barat', 'Jl. Gubernur Bastari No.3, Palembang', '0711-9012099'),
(100, 10, 'Kampus Pontianak Utara', 'Jl. Khatulistiwa No.8, Pontianak', '0561-0123100');

-- ------------------------------------------------------------
-- 4. DATA FASILITAS
-- ------------------------------------------------------------
INSERT INTO fasilitas (idFasilitas, namaFasilitas) VALUES 
(1, 'Proyektor'), (2, 'Papan Tulis'), (3, 'Air Conditioner'), (4, 'Komputer'), 
(5, 'Meja Belajar'), (6, 'Kursi'), (7, 'Podium'), (8, 'Mikrofon'), 
(9, 'Speaker'), (10, 'Layar Proyektor'), (11, 'Whiteboard Interaktif'), (12, 'Webcam'), 
(13, 'TV Monitor'), (14, 'Locker'), (15, 'Lemari Arsip'), (16, 'Printer'), 
(17, 'Scanner'), (18, 'UPS'), (19, 'Stop Kontak'), (20, 'WiFi Router'), 
(21, 'CCTV'), (22, 'Fingerprint Scanner'), (23, 'Papan Pengumuman'), (24, 'Jam Dinding'), 
(25, 'Cermin'), (26, 'Gorden'), (27, 'Exhaust Fan'), (28, 'Kipas Angin'), 
(29, 'Dispenser Air'), (30, 'Kulkas Mini'), (31, 'Microwave'), (32, 'Kamera DSLR'), 
(33, 'Tripod'), (34, 'Green Screen'), (35, 'Studio Lighting'), (36, 'Meja Dosen'), 
(37, 'Kursi Dosen'), (38, 'Rak Buku'), (39, 'Filing Cabinet'), (40, 'Brankas'), 
(41, 'Meja Rapat'), (42, 'Kursi Rapat'), (43, 'Papan Flipchart'), (44, 'Marker Board'), 
(45, 'Pointer Laser'), (46, 'Remote Proyektor'), (47, 'HDMI Switcher'), (48, 'Video Conference System'), 
(49, 'Telephone Intercom'), (50, 'Fire Extinguisher'), (51, 'P3K Kit'), (52, 'Tanda Darurat'), 
(53, 'Smoke Detector'), (54, 'Emergency Light'), (55, 'Blind/Tirai'), (56, 'Karpet'), 
(57, 'Podium Portable'), (58, 'Meja Seminar'), (59, 'Backdrop Banner'), (60, 'Lighting Panggung'), 
(61, 'Sound System'), (62, 'Mixer Audio'), (63, 'Headset'), (64, 'Keyboard Piano'), 
(65, 'Gitar'), (66, 'Drum Set'), (67, 'Meja Lab'), (68, 'Kursi Lab'), 
(69, 'Lemari Alat'), (70, 'Laci Alat'), (71, 'Wastafel'), (72, 'Autoclave'), 
(73, 'Centrifuge'), (74, 'Mikroskop'), (75, 'Inkubator'), (76, 'Lemari Asam'), 
(77, 'Timbangan Analitik'), (78, 'Hot Plate'), (79, 'Magnetic Stirrer'), (80, 'pH Meter'), 
(81, 'Spektrofotometer'), (82, 'Sonikator'), (83, 'Vortex Mixer'), (84, 'Pipet Otomatis'), 
(85, 'Kulkas Lab'), (86, 'Freezer Lab'), (87, 'Mesin PCR'), (88, 'Electrophoresis Set'), 
(89, 'Flow Cytometer'), (90, 'Laminar Air Flow'), (91, 'Scanning Electron Microscope'), (92, 'Oven Lab'), 
(93, 'Desiccator'), (94, 'Buret Stand'), (95, 'Klem Universal'), (96, 'Erlenmeyer Besar'), 
(97, 'Gelas Beker'), (98, 'Tabung Reaksi'), (99, 'Pipet Tetes'), (100, 'Labu Ukur');

-- ------------------------------------------------------------
-- 5. DATA GEDUNG
-- ------------------------------------------------------------
INSERT INTO gedung (idGedung, idCabang, kodeGedung, namaGedung, jumlahLantai, idFakultas) VALUES 
(1, 1, 'GD-A01', 'Gedung Teknik A', 5, 1),
(2, 1, 'GD-B01', 'Gedung Ilmu Komputer B', 4, 2),
(3, 1, 'GD-C01', 'Gedung Ekonomi C', 3, 3),
(4, 1, 'GD-D01', 'Gedung Hukum D', 4, 4),
(5, 1, 'GD-E01', 'Gedung Kedokteran E', 6, 5),
(6, 1, 'GD-F01', 'Gedung Rektorat', 4, NULL),
(7, 1, 'GD-G01', 'Gedung Serbaguna', 2, NULL),
(8, 2, 'GD-A02', 'Gedung Teknik A Cimahi', 5, 1),
(9, 2, 'GD-B02', 'Gedung Ilmu Komputer B Cimahi', 4, 2),
(10, 2, 'GD-C02', 'Gedung Serbaguna Cimahi', 2, NULL),
(11, 3, 'GD-A03', 'Gedung Teknik Sumedang', 5, 1),
(12, 3, 'GD-B03', 'Gedung Umum Sumedang', 3, NULL),
(13, 4, 'GD-A04', 'Gedung Teknik Garut', 4, 1),
(14, 4, 'GD-B04', 'Gedung Ekonomi Garut', 3, 3),
(15, 4, 'GD-C04', 'Gedung Umum Garut', 2, NULL),
(16, 5, 'GD-A05', 'Gedung Teknik Tasik', 5, 1),
(17, 5, 'GD-B05', 'Gedung Farmasi Tasik', 3, 6),
(18, 5, 'GD-C05', 'Gedung Serbaguna Tasik', 2, NULL),
(19, 6, 'GD-A06', 'Gedung Teknik Majalengka', 4, 1),
(20, 6, 'GD-B06', 'Gedung Umum Majalengka', 2, NULL),
(21, 7, 'GD-A07', 'Gedung Teknik Cianjur', 4, 1),
(22, 7, 'GD-B07', 'Gedung ISIP Cianjur', 3, 8),
(23, 8, 'GD-A08', 'Gedung Teknik Purwakarta', 5, 1),
(24, 8, 'GD-B08', 'Gedung Ilmu Komputer Purwakarta', 4, 2),
(25, 8, 'GD-C08', 'Gedung Serba Guna Purwakarta', 2, NULL),
(26, 9, 'GD-A09', 'Gedung Teknik Karawang', 5, 1),
(27, 9, 'GD-B09', 'Gedung Serbaguna Karawang', 2, NULL),
(28, 10, 'GD-A10', 'Gedung Teknik Subang', 4, 1),
(29, 10, 'GD-B10', 'Gedung Umum Subang', 2, NULL),
(30, 11, 'GD-A11', 'Gedung Teknik Jakarta', 6, 1),
(31, 11, 'GD-B11', 'Gedung Ilmu Komputer Jakarta', 5, 2),
(32, 11, 'GD-C11', 'Gedung Ekonomi Jakarta', 4, 3),
(33, 11, 'GD-D11', 'Gedung Serbaguna Jakarta', 3, NULL),
(34, 12, 'GD-A12', 'Gedung Teknik Depok', 5, 1),
(35, 12, 'GD-B12', 'Gedung Psikologi Depok', 4, 7),
(36, 12, 'GD-C12', 'Gedung Umum Depok', 2, NULL),
(37, 13, 'GD-A13', 'Gedung Teknik Bekasi', 5, 1),
(38, 13, 'GD-B13', 'Gedung Hukum Bekasi', 4, 4),
(39, 13, 'GD-C13', 'Gedung Serbaguna Bekasi', 2, NULL),
(40, 14, 'GD-A14', 'Gedung Teknik Tangerang', 5, 1),
(41, 14, 'GD-B14', 'Gedung Serbaguna Tangerang', 3, NULL),
(42, 15, 'GD-A15', 'Gedung Teknik Bogor', 5, 1),
(43, 15, 'GD-B15', 'Gedung Pertanian Bogor', 4, 9),
(44, 15, 'GD-C15', 'Gedung Umum Bogor', 2, NULL),
(45, 16, 'GD-A16', 'Gedung Teknik Surabaya', 6, 1),
(46, 16, 'GD-B16', 'Gedung Kedokteran Surabaya', 6, 5),
(47, 16, 'GD-C16', 'Gedung Ilmu Komputer Surabaya', 5, 2),
(48, 16, 'GD-D16', 'Gedung Serbaguna Surabaya', 3, NULL),
(49, 17, 'GD-A17', 'Gedung Teknik Malang', 5, 1),
(50, 17, 'GD-B17', 'Gedung Ekonomi Malang', 4, 3),
(51, 17, 'GD-C17', 'Gedung Umum Malang', 2, NULL),
(52, 18, 'GD-A18', 'Gedung Teknik Sidoarjo', 5, 1),
(53, 18, 'GD-B18', 'Gedung Serbaguna Sidoarjo', 2, NULL),
(54, 21, 'GD-A21', 'Gedung Teknik Yogyakarta', 5, 1),
(55, 21, 'GD-B21', 'Gedung Kedokteran Yogyakarta', 6, 5),
(56, 21, 'GD-C21', 'Gedung Ilmu Komputer Yogya', 4, 2),
(57, 21, 'GD-D21', 'Gedung Serbaguna Yogya', 2, NULL),
(58, 22, 'GD-A22', 'Gedung Teknik Sleman', 4, 1),
(59, 22, 'GD-B22', 'Gedung Umum Sleman', 2, NULL),
(60, 26, 'GD-A26', 'Gedung Teknik Semarang', 5, 1),
(61, 26, 'GD-B26', 'Gedung Ilmu Komputer Semarang', 4, 2),
(62, 26, 'GD-C26', 'Gedung Serbaguna Semarang', 3, NULL),
(63, 31, 'GD-A31', 'Gedung Teknik Medan', 6, 1),
(64, 31, 'GD-B31', 'Gedung Ilmu Komputer Medan', 5, 2),
(65, 31, 'GD-C31', 'Gedung Kedokteran Medan', 6, 5),
(66, 31, 'GD-D31', 'Gedung Serbaguna Medan', 3, NULL),
(67, 36, 'GD-A36', 'Gedung Teknik Makassar', 6, 1),
(68, 36, 'GD-B36', 'Gedung Ilmu Komputer Makassar', 5, 2),
(69, 36, 'GD-C36', 'Gedung Serbaguna Makassar', 3, NULL),
(70, 41, 'GD-A41', 'Gedung Teknik Padang', 5, 1),
(71, 41, 'GD-B41', 'Gedung Ilmu Komputer Padang', 4, 2),
(72, 41, 'GD-C41', 'Gedung Serbaguna Padang', 2, NULL),
(73, 46, 'GD-A46', 'Gedung Teknik Palembang', 5, 1),
(74, 46, 'GD-B46', 'Gedung Ekonomi Palembang', 4, 3),
(75, 46, 'GD-C46', 'Gedung Umum Palembang', 2, NULL),
(76, 51, 'GD-A51', 'Gedung Teknik Pontianak', 5, 1),
(77, 51, 'GD-B51', 'Gedung Serbaguna Pontianak', 2, NULL),
(78, 1, 'GD-H01', 'Gedung Psikologi H', 3, 7),
(79, 1, 'GD-I01', 'Gedung ISIP I', 3, 8),
(80, 1, 'GD-J01', 'Gedung Pertanian J', 4, 9),
(81, 1, 'GD-K01', 'Gedung Farmasi K', 3, 6),
(82, 1, 'GD-L01', 'Gedung Matematika IPA L', 4, 13),
(83, 11, 'GD-E11', 'Gedung Hukum Jakarta E', 4, 4),
(84, 11, 'GD-F11', 'Gedung Farmasi Jakarta F', 3, 6),
(85, 16, 'GD-E16', 'Gedung Ekonomi Surabaya E', 4, 3),
(86, 21, 'GD-E21', 'Gedung Ekonomi Yogya E', 3, 3),
(87, 26, 'GD-D26', 'Gedung Kedokteran Semarang D', 6, 5),
(88, 31, 'GD-E31', 'Gedung Ekonomi Medan E', 4, 3),
(89, 36, 'GD-D36', 'Gedung Kedokteran Makassar D', 6, 5),
(90, 36, 'GD-E36', 'Gedung Hukum Makassar E', 4, 4),
(91, 2, 'GD-D02', 'Gedung Ekonomi Cimahi D', 3, 3),
(92, 12, 'GD-D12', 'Gedung Ekonomi Depok D', 3, 3),
(93, 17, 'GD-D17', 'Gedung Psikologi Malang D', 3, 7),
(94, 22, 'GD-C22', 'Gedung Psikologi Sleman C', 3, 7),
(95, 32, 'GD-A32', 'Gedung Teknik Bekasi 2', 5, 1),
(96, 1, 'GD-M01', 'Gedung Pendidikan M', 4, 14),
(97, 1, 'GD-N01', 'Gedung Bahasa Sastra N', 3, 15),
(98, 11, 'GD-G11', 'Gedung Pendidikan Jakarta G', 3, 14),
(99, 16, 'GD-F16', 'Gedung Pertanian Surabaya F', 4, 9),
(100, 21, 'GD-F21', 'Gedung Pertanian Yogya F', 3, 9);

-- ------------------------------------------------------------
-- 6. DATA RUANGAN
-- ------------------------------------------------------------
INSERT INTO ruangan (idRuangan, idGedung, lokasiLantai, kategoriRuangan, namaRuangan, nomorRuangan, kapasitas, statusRuangan) VALUES 
(1, 1, 1, 'Kelas', 'Ruang Kuliah A101', 'A101', 40, 'Tersedia'),
(2, 1, 1, 'Kelas', 'Ruang Kuliah A102', 'A102', 40, 'Tersedia'),
(3, 1, 2, 'Kelas', 'Ruang Kuliah A201', 'A201', 40, 'Tersedia'),
(4, 1, 2, 'Kelas', 'Ruang Kuliah A202', 'A202', 40, 'Tersedia'),
(5, 1, 3, 'Laboratorium', 'Lab Jaringan A301', 'A301', 30, 'Tersedia'),
(6, 1, 3, 'Laboratorium', 'Lab Pemrograman A302', 'A302', 30, 'Tersedia'),
(7, 1, 4, 'Seminar', 'Ruang Seminar A401', 'A401', 100, 'Tersedia'),
(8, 1, 5, 'Aula', 'Aula Teknik A501', 'A501', 300, 'Tersedia'),
(9, 2, 1, 'Kelas', 'Ruang Kuliah B101', 'B101', 40, 'Tersedia'),
(10, 2, 1, 'Kelas', 'Ruang Kuliah B102', 'B102', 40, 'Tersedia'),
(11, 2, 2, 'Kelas', 'Ruang Kuliah B201', 'B201', 40, 'Tersedia'),
(12, 2, 2, 'Laboratorium', 'Lab Komputer B202', 'B202', 35, 'Tersedia'),
(13, 2, 3, 'Laboratorium', 'Lab Multimedia B301', 'B301', 30, 'Tersedia'),
(14, 2, 4, 'Seminar', 'Ruang Seminar B401', 'B401', 80, 'Tersedia'),
(15, 3, 1, 'Kelas', 'Ruang Kuliah C101', 'C101', 40, 'Tersedia'),
(16, 3, 1, 'Kelas', 'Ruang Kuliah C102', 'C102', 40, 'Tersedia'),
(17, 3, 2, 'Seminar', 'Ruang Seminar C201', 'C201', 80, 'Tersedia'),
(18, 3, 3, 'Rapat', 'Ruang Rapat C301', 'C301', 20, 'Tersedia'),
(19, 4, 1, 'Kelas', 'Ruang Kuliah D101', 'D101', 40, 'Tersedia'),
(20, 4, 2, 'Kelas', 'Ruang Kuliah D201', 'D201', 40, 'Tersedia'),
(21, 4, 3, 'Seminar', 'Ruang Seminar D301', 'D301', 80, 'Tersedia'),
(22, 5, 1, 'Kelas', 'Ruang Kuliah E101', 'E101', 40, 'Tersedia'),
(23, 5, 2, 'Laboratorium', 'Lab Anatomi E201', 'E201', 20, 'Tersedia'),
(24, 5, 3, 'Laboratorium', 'Lab Fisiologi E301', 'E301', 20, 'Tersedia'),
(25, 5, 4, 'Seminar', 'Ruang Seminar E401', 'E401', 60, 'Tersedia'),
(26, 6, 1, 'Rapat', 'Ruang Rapat F101', 'F101', 20, 'Tersedia'),
(27, 6, 2, 'Aula', 'Aula Rektorat F201', 'F201', 200, 'Tersedia'),
(28, 7, 1, 'Aula', 'Aula Serbaguna G101', 'G101', 500, 'Tersedia'),
(29, 7, 2, 'Seminar', 'Ruang Seminar G201', 'G201', 100, 'Tersedia'),
(30, 8, 1, 'Kelas', 'Ruang Kuliah A101-Cm', 'A101', 40, 'Tersedia'),
(31, 8, 2, 'Kelas', 'Ruang Kuliah A201-Cm', 'A201', 40, 'Tersedia'),
(32, 8, 3, 'Laboratorium', 'Lab Teknik A301-Cm', 'A301', 30, 'Tersedia'),
(33, 9, 1, 'Kelas', 'Ruang Kuliah B101-Cm', 'B101', 40, 'Tersedia'),
(34, 9, 2, 'Laboratorium', 'Lab Komputer B201-Cm', 'B201', 35, 'Tersedia'),
(35, 10, 1, 'Aula', 'Aula Cimahi G101', 'G101', 400, 'Tersedia'),
(36, 11, 1, 'Kelas', 'Ruang Kuliah A101-Sm', 'A101', 40, 'Tersedia'),
(37, 11, 2, 'Kelas', 'Ruang Kuliah A201-Sm', 'A201', 40, 'Tersedia'),
(38, 12, 1, 'Aula', 'Aula Umum Sumedang', 'G101', 400, 'Tersedia'),
(39, 13, 1, 'Kelas', 'Ruang Kuliah A101-Gr', 'A101', 40, 'Tersedia'),
(40, 14, 1, 'Kelas', 'Ruang Kuliah C101-Gr', 'C101', 40, 'Tersedia'),
(41, 15, 1, 'Aula', 'Aula Umum Garut', 'G101', 300, 'Tersedia'),
(42, 16, 1, 'Kelas', 'Ruang Kuliah A101-Ts', 'A101', 40, 'Tersedia'),
(43, 17, 1, 'Kelas', 'Ruang Kuliah K101-Ts', 'K101', 40, 'Tersedia'),
(44, 18, 1, 'Aula', 'Aula Serbaguna Tasik', 'G101', 300, 'Tersedia'),
(45, 30, 1, 'Kelas', 'Ruang Kuliah A101-Jkt', 'A101', 40, 'Tersedia'),
(46, 30, 2, 'Kelas', 'Ruang Kuliah A201-Jkt', 'A201', 40, 'Tersedia'),
(47, 30, 3, 'Laboratorium', 'Lab Teknik A301-Jkt', 'A301', 30, 'Tersedia'),
(48, 31, 1, 'Kelas', 'Ruang Kuliah B101-Jkt', 'B101', 40, 'Tersedia'),
(49, 31, 2, 'Laboratorium', 'Lab Komputer B201-Jkt', 'B201', 35, 'Tersedia'),
(50, 32, 1, 'Kelas', 'Ruang Kuliah C101-Jkt', 'C101', 40, 'Tersedia'),
(51, 33, 1, 'Aula', 'Aula Serbaguna Jakarta', 'G101', 500, 'Tersedia'),
(52, 45, 1, 'Kelas', 'Ruang Kuliah A101-Sby', 'A101', 40, 'Tersedia'),
(53, 45, 2, 'Laboratorium', 'Lab Teknik A201-Sby', 'A201', 30, 'Tersedia'),
(54, 46, 1, 'Kelas', 'Ruang Kuliah E101-Sby', 'E101', 40, 'Tersedia'),
(55, 46, 2, 'Laboratorium', 'Lab Anatomi E201-Sby', 'E201', 20, 'Tersedia'),
(56, 47, 1, 'Kelas', 'Ruang Kuliah B101-Sby', 'B101', 40, 'Tersedia'),
(57, 48, 1, 'Aula', 'Aula Serbaguna Sby', 'G101', 500, 'Tersedia'),
(58, 54, 1, 'Kelas', 'Ruang Kuliah A101-Yk', 'A101', 40, 'Tersedia'),
(59, 54, 2, 'Laboratorium', 'Lab Teknik A201-Yk', 'A201', 30, 'Tersedia'),
(60, 55, 1, 'Kelas', 'Ruang Kuliah E101-Yk', 'E101', 40, 'Tersedia'),
(61, 56, 1, 'Kelas', 'Ruang Kuliah B101-YK', 'B101', 40, 'Tersedia'),
(62, 57, 1, 'Aula', 'Aula Serbaguna Yogya', 'G101', 400, 'Tersedia'),
(63, 60, 1, 'Kelas', 'Ruang Kuliah A101-Smg', 'A101', 40, 'Tersedia'),
(64, 61, 1, 'Kelas', 'Ruang Kuliah B101-Smg', 'B101', 40, 'Tersedia'),
(65, 62, 1, 'Aula', 'Aula Serbaguna Semarang', 'G101', 500, 'Tersedia'),
(66, 63, 1, 'Kelas', 'Ruang Kuliah A101-Mdn', 'A101', 40, 'Tersedia'),
(67, 64, 1, 'Kelas', 'Ruang Kuliah B101-Mdn', 'B101', 40, 'Tersedia'),
(68, 65, 1, 'Kelas', 'Ruang Kuliah E101-Mdn', 'E101', 40, 'Tersedia'),
(69, 66, 1, 'Aula', 'Aula Serbaguna Medan', 'G101', 500, 'Tersedia'),
(70, 67, 1, 'Kelas', 'Ruang Kuliah A101-Mks', 'A101', 40, 'Tersedia'),
(71, 68, 1, 'Kelas', 'Ruang Kuliah B101-Mks', 'B101', 40, 'Tersedia'),
(72, 69, 1, 'Aula', 'Aula Serbaguna Makassar', 'G101', 500, 'Tersedia'),
(73, 1, 1, 'Rapat', 'Ruang Rapat A103', 'A103', 15, 'Tersedia'),
(74, 2, 3, 'Rapat', 'Ruang Rapat B302', 'B302', 15, 'Tersedia'),
(75, 5, 5, 'Laboratorium', 'Lab Mikrobiologi E501', 'E501', 20, 'Tersedia'),
(76, 1, 4, 'Laboratorium', 'Lab Hardware A401', 'A401b', 25, 'Tersedia'),
(77, 30, 4, 'Seminar', 'Ruang Seminar A401-Jkt', 'A401', 80, 'Tersedia'),
(78, 45, 3, 'Seminar', 'Ruang Seminar A301-Sby', 'A301', 80, 'Tersedia'),
(79, 54, 3, 'Seminar', 'Ruang Seminar A301-Yk', 'A301', 80, 'Tersedia'),
(80, 63, 2, 'Seminar', 'Ruang Seminar A201-Mdn', 'A201', 80, 'Tersedia'),
(81, 67, 2, 'Seminar', 'Ruang Seminar A201-Mks', 'A201', 80, 'Tersedia'),
(82, 6, 3, 'Rapat', 'Ruang Rapat F301', 'F301', 25, 'Tersedia'),
(83, 6, 4, 'Rapat', 'Ruang Rapat F401', 'F401', 25, 'Tersedia'),
(84, 3, 2, 'Kelas', 'Ruang Kuliah C201', 'C201', 40, 'Tersedia'),
(85, 4, 4, 'Rapat', 'Ruang Rapat D401', 'D401', 20, 'Tersedia'),
(86, 78, 1, 'Kelas', 'Ruang Kuliah H101', 'H101', 40, 'Tersedia'),
(87, 79, 1, 'Kelas', 'Ruang Kuliah I101', 'I101', 40, 'Tersedia'),
(88, 80, 1, 'Laboratorium', 'Lab Agronomi J101', 'J101', 25, 'Tersedia'),
(89, 81, 1, 'Laboratorium', 'Lab Farmasi K101', 'K101', 25, 'Tersedia'),
(90, 82, 1, 'Laboratorium', 'Lab Matematika L101', 'L101', 30, 'Tersedia'),
(91, 83, 1, 'Kelas', 'Ruang Kuliah E101-Jkt', 'E101', 40, 'Tersedia'),
(92, 84, 1, 'Laboratorium', 'Lab Farmasi Jkt K101', 'K101', 25, 'Tersedia'),
(93, 85, 1, 'Kelas', 'Ruang Kuliah C101-Sby', 'C101', 40, 'Tersedia'),
(94, 86, 1, 'Kelas', 'Ruang Kuliah C101-Yk', 'C101', 40, 'Tersedia'),
(95, 87, 1, 'Kelas', 'Ruang Kuliah E101-Smg', 'E101', 40, 'Tersedia'),
(96, 88, 1, 'Kelas', 'Ruang Kuliah C101-Mdn', 'C101', 40, 'Tersedia'),
(97, 89, 1, 'Kelas', 'Ruang Kuliah E101-Mks', 'E101', 40, 'Tersedia'),
(98, 90, 1, 'Kelas', 'Ruang Kuliah D101-Mks', 'D101', 40, 'Tersedia'),
(99, 96, 1, 'Kelas', 'Ruang Kuliah M101', 'M101', 40, 'Tersedia'),
(100, 97, 1, 'Kelas', 'Ruang Kuliah N101', 'N101', 40, 'Tersedia');

-- ------------------------------------------------------------
-- 7. DATA DETAIL FASILITAS
-- ------------------------------------------------------------
INSERT INTO detailFasilitas (idFasilitas, idRuangan, jumlahFasilitas) VALUES 
(1, 1, 1), (2, 1, 2), (3, 1, 1), (5, 1, 20), (6, 1, 40),
(1, 2, 1), (2, 2, 2), (3, 2, 1), (5, 2, 20), (6, 2, 40),
(1, 3, 1), (3, 3, 1), (6, 3, 40),
(4, 5, 30), (5, 5, 30), (6, 5, 30), (20, 5, 1),
(4, 6, 30), (5, 6, 30), (6, 6, 30), (20, 6, 1),
(1, 7, 2), (3, 7, 2), (6, 7, 100), (9, 7, 2), (10, 7, 2),
(1, 8, 4), (3, 8, 4), (6, 8, 300), (9, 8, 4), (8, 8, 4),
(1, 9, 1), (3, 9, 1), (5, 9, 20), (6, 9, 40),
(4, 12, 35), (5, 12, 35), (6, 12, 35), (20, 12, 1),
(74, 23, 5), (75, 23, 2), (5, 23, 10), (6, 23, 20),
(74, 24, 3), (78, 24, 2), (79, 24, 2), (80, 24, 1),
(50, 28, 2), (51, 28, 2), (52, 28, 4), (53, 28, 4),
(1, 29, 2), (3, 29, 2), (6, 29, 100), (9, 29, 2),
(48, 27, 1), (8, 27, 4), (9, 27, 4), (3, 27, 2),
(1, 51, 4), (3, 51, 4), (6, 51, 500), (9, 51, 4), (8, 51, 4);

-- ------------------------------------------------------------
-- 8. DATA PENGGUNA
-- ------------------------------------------------------------
INSERT INTO pengguna (idPengguna, idCabang, idFakultas, rolePengguna, namaLengkap, namaPengguna, nomorPengguna) VALUES 
(1, 1, 1, 'Mahasiswa', 'Andi Prasetyo', 'andiprasetyo', '081200000001'),
(2, 1, 1, 'Mahasiswa', 'Budi Santoso', 'budisantoso', '081200000002'),
(3, 1, 2, 'Mahasiswa', 'Citra Dewi', 'citradewi', '081200000003'),
(4, 1, 2, 'Mahasiswa', 'Dian Pertiwi', 'dianpertiwi', '081200000004'),
(5, 1, 3, 'Mahasiswa', 'Eko Nugroho', 'ekonugroho', '081200000005'),
(6, 1, 3, 'Mahasiswa', 'Fina Rahayu', 'finarahayu', '081200000006'),
(7, 1, 4, 'Mahasiswa', 'Gilang Ramadhan', 'gilangr', '081200000007'),
(8, 1, 4, 'Mahasiswa', 'Hesti Lestari', 'hestilestari', '081200000008'),
(9, 1, 5, 'Mahasiswa', 'Irfan Maulana', 'irfanm', '081200000009'),
(10, 1, 5, 'Mahasiswa', 'Joko Widodo', 'jokowidodo', '081200000010'),
(11, 1, 1, 'Dosen', 'Dr. Kasim Subroto', 'kasubr', '081200000011'),
(12, 1, 2, 'Dosen', 'Dr. Liana Sari', 'lianasari', '081200000012'),
(13, 1, 3, 'Dosen', 'Prof. Maman Abdurahman', 'mamanabdurahman', '081200000013'),
(14, 1, 4, 'Dosen', 'Dr. Nina Kartika', 'ninakartika', '081200000014'),
(15, 1, 5, 'Dosen', 'Prof. Oki Firmansyah', 'okifirmansyah', '081200000015'),
(16, 1, 1, 'Staff', 'Pandu Wibowo', 'panduwibowo', '081200000016'),
(17, 1, 2, 'Staff', 'Qori Handayani', 'qorihandayani', '081200000017'),
(18, 1, 3, 'Staff', 'Rudi Hermawan', 'rudihermawan', '081200000018'),
(19, 1, 4, 'Staff', 'Sari Indah', 'sariindah', '081200000019'),
(20, 1, 5, 'Staff', 'Teguh Santosa', 'teguhsantosa', '081200000020'),
(21, 2, 1, 'Mahasiswa', 'Umar Faruq', 'umarfaruq', '081200000021'),
(22, 2, 1, 'Mahasiswa', 'Vina Anggraeni', 'vinaanggraeni', '081200000022'),
(23, 2, 2, 'Mahasiswa', 'Wahyu Setiawan', 'wahyusetiawan', '081200000023'),
(24, 2, 2, 'Mahasiswa', 'Xena Putri', 'xenaputri', '081200000024'),
(25, 2, 3, 'Mahasiswa', 'Yogi Pratama', 'yogipratama', '081200000025'),
(26, 2, 3, 'Mahasiswa', 'Zahra Mutiara', 'zahramutiara', '081200000026'),
(27, 2, 1, 'Dosen', 'Dr. Ahmad Fauzi', 'ahmadfauzi', '081200000027'),
(28, 2, 2, 'Dosen', 'Dr. Bella Susanti', 'bellasusanti', '081200000028'),
(29, 2, 3, 'Dosen', 'Prof. Cahyo Nugroho', 'cahyonugroho', '081200000029'),
(30, 2, 1, 'Staff', 'Dewi Kurniawati', 'dewikurniawati', '081200000030'),
(31, 3, 1, 'Mahasiswa', 'Evan Saputra', 'evansaputra', '081200000031'),
(32, 3, 1, 'Mahasiswa', 'Farida Hanum', 'faridahanum', '081200000032'),
(33, 3, 6, 'Mahasiswa', 'Gunawan Prasetya', 'gunawanp', '081200000033'),
(34, 3, 7, 'Mahasiswa', 'Halimah Azzahra', 'halimahazzahra', '081200000034'),
(35, 3, 1, 'Dosen', 'Dr. Ihsan Budiarto', 'ihsanbudiarto', '081200000035'),
(36, 3, 6, 'Dosen', 'Dr. Jihan Kusuma', 'jihankusuma', '081200000036'),
(37, 3, 1, 'Staff', 'Kartini Wijaya', 'kartiniwijaya', '081200000037'),
(38, 4, 1, 'Mahasiswa', 'Lutfi Hakim', 'lutfihakim', '081200000038'),
(39, 4, 3, 'Mahasiswa', 'Melati Indraswari', 'melatiindraswari', '081200000039'),
(40, 4, 1, 'Dosen', 'Prof. Nanang Kosim', 'nanangkosim', '081200000040'),
(41, 5, 1, 'Mahasiswa', 'Odin Siregar', 'odinsiregar', '081200000041'),
(42, 5, 6, 'Mahasiswa', 'Putri Larasati', 'putrilarasati', '081200000042'),
(43, 5, 1, 'Dosen', 'Dr. Qudrat Alam', 'qudratalam', '081200000043'),
(44, 6, 1, 'Mahasiswa', 'Rahmat Hidayat', 'rahmath', '081200000044'),
(45, 6, 8, 'Mahasiswa', 'Sinta Maharani', 'sintamaharani', '081200000045'),
(46, 6, 1, 'Dosen', 'Dr. Taufik Hidayatullah', 'taufikhidayat', '081200000046'),
(47, 7, 1, 'Mahasiswa', 'Udin Syaifudin', 'udinsyaifudin', '081200000047'),
(48, 7, 1, 'Dosen', 'Prof. Vera Andriani', 'veraandriani', '081200000048'),
(49, 8, 1, 'Mahasiswa', 'Wahid Anshori', 'wahidanshori', '081200000049'),
(50, 8, 2, 'Mahasiswa', 'Yeni Kusuma', 'yenikusuma', '081200000050'),
(51, 8, 1, 'Dosen', 'Dr. Zainal Abidin', 'zainalabidin', '081200000051'),
(52, 9, 1, 'Mahasiswa', 'Agus Pramono', 'aguspramono', '081200000052'),
(53, 9, 2, 'Mahasiswa', 'Bagas Wicaksono', 'bagaswicaksono', '081200000053'),
(54, 9, 1, 'Dosen', 'Prof. Catur Hendra', 'caturhendra', '081200000054'),
(55, 10, 1, 'Mahasiswa', 'Dimas Ardianto', 'dimasardianto', '081200000055'),
(56, 10, 1, 'Dosen', 'Dr. Eka Wulandari', 'ekawulandari', '081200000056'),
(57, 11, 1, 'Mahasiswa', 'Fajar Nugroho', 'fajarnugroho', '081200000057'),
(58, 11, 1, 'Mahasiswa', 'Galih Permana', 'galihpermana', '081200000058'),
(59, 11, 2, 'Mahasiswa', 'Hana Safitri', 'hanasafitri', '081200000059'),
(60, 11, 2, 'Mahasiswa', 'Ilham Ramadhan', 'ilhamramadhan', '081200000060'),
(61, 11, 1, 'Dosen', 'Prof. Jati Kusuma', 'jatikusuma', '081200000061'),
(62, 11, 2, 'Dosen', 'Dr. Kiki Rahmawati', 'kikirm', '081200000062'),
(63, 11, 3, 'Dosen', 'Prof. Luthfi Anwar', 'luthfianwar', '081200000063'),
(64, 11, 1, 'Staff', 'Maya Puspita', 'mayapuspita', '081200000064'),
(65, 12, 1, 'Mahasiswa', 'Nanda Baskara', 'nandabaskara', '081200000065'),
(66, 12, 7, 'Mahasiswa', 'Okta Fitriani', 'oktafitriani', '081200000066'),
(67, 12, 1, 'Dosen', 'Dr. Panji Kusuma', 'panjikusuma', '081200000067'),
(68, 13, 1, 'Mahasiswa', 'Qaisar Albani', 'qaisaralbani', '081200000068'),
(69, 13, 4, 'Mahasiswa', 'Rara Setiawati', 'rarasetiawati', '081200000069'),
(70, 13, 1, 'Dosen', 'Prof. Sigit Priyanto', 'sigitpriyanto', '081200000070'),
(71, 14, 1, 'Mahasiswa', 'Tia Rahmadani', 'tiarahmadani', '081200000071'),
(72, 14, 1, 'Dosen', 'Dr. Ucok Situmorang', 'ucoksitumorang', '081200000072'),
(73, 15, 1, 'Mahasiswa', 'Vita Anggunansyah', 'vitaanggun', '081200000073'),
(74, 15, 9, 'Mahasiswa', 'Wulan Dari', 'wulandari', '081200000074'),
(75, 15, 1, 'Dosen', 'Prof. Xander Halim', 'xanderhalim', '081200000075'),
(76, 16, 1, 'Mahasiswa', 'Yuda Mahendra', 'yudamahendra', '081200000076'),
(77, 16, 5, 'Mahasiswa', 'Zaynab Azzahra', 'zaynabazzahra', '081200000077'),
(78, 16, 1, 'Dosen', 'Dr. Ahmad Thohir', 'ahmadthohir', '081200000078'),
(79, 16, 5, 'Dosen', 'Prof. Bintang Hakim', 'bintanghakim', '081200000079'),
(80, 16, 1, 'Staff', 'Cantika Dewi', 'cantikadewi', '081200000080'),
(81, 21, 1, 'Mahasiswa', 'Danu Wibawa', 'danuwibawa', '081200000081'),
(82, 21, 5, 'Mahasiswa', 'Erna Sumiati', 'ernasumiati', '081200000082'),
(83, 21, 2, 'Mahasiswa', 'Fikri Ramadhan', 'fikriramadhan', '081200000083'),
(84, 21, 1, 'Dosen', 'Dr. Gita Suryana', 'gitasuryana', '081200000084'),
(85, 26, 1, 'Mahasiswa', 'Hamdan Yunus', 'hamdanyunus', '081200000085'),
(86, 26, 2, 'Mahasiswa', 'Intan Permata', 'intanpermata', '081200000086'),
(87, 26, 1, 'Dosen', 'Prof. Jadmiko Santoso', 'jadmikosantoso', '081200000087'),
(88, 31, 1, 'Mahasiswa', 'Khoirul Anwar', 'khoirulanwar', '081200000088'),
(89, 31, 5, 'Mahasiswa', 'Lilis Suryani', 'lilissuryani', '081200000089'),
(90, 31, 1, 'Dosen', 'Dr. Mukhlis Harahap', 'mukhlisharahap', '081200000090'),
(91, 36, 1, 'Mahasiswa', 'Nur Hidayah', 'nurhidayah', '081200000091'),
(92, 36, 5, 'Mahasiswa', 'Omar Abdillah', 'omarabdillah', '081200000092'),
(93, 36, 1, 'Dosen', 'Prof. Patta Bundu', 'pattabundu', '081200000093'),
(94, 41, 1, 'Mahasiswa', 'Rini Suriani', 'rinisuriani', '081200000094'),
(95, 41, 1, 'Dosen', 'Dr. Sabri Nasution', 'sabrinasution', '081200000095'),
(96, 46, 1, 'Mahasiswa', 'Toni Sofyan', 'tonisofyan', '081200000096'),
(97, 46, 3, 'Mahasiswa', 'Ummu Habibah', 'ummuhabibah', '081200000097'),
(98, 46, 1, 'Dosen', 'Prof. Veri Indra', 'veriindra', '081200000098'),
(99, 51, 1, 'Mahasiswa', 'Wendi Satriani', 'wendisatriani', '081200000099'),
(100, 51, 1, 'Dosen', 'Dr. Yusron Zain', 'yusronzain', '081200000100'),
(101, 1, 1, 'Staff', 'Arif Budiman', 'arifbudiman', '081200000101'),
(102, 1, 2, 'Staff', 'Berta Sanjaya', 'bertasanjaya', '081200000102'),
(103, 1, 3, 'Staff', 'Choirul Umam', 'choirulumam', '081200000103'),
(104, 1, 4, 'Staff', 'Dodi Sulistyo', 'dodisulistyo', '081200000104'),
(105, 1, 5, 'Staff', 'Elsa Mariana', 'elsamariana', '081200000105'),
(106, 2, 1, 'Staff', 'Fahmi Zulfikar', 'fahmizulfikar', '081200000106'),
(107, 2, 2, 'Staff', 'Gina Permata', 'ginapermata', '081200000107'),
(108, 2, 3, 'Staff', 'Hendra Wijaya', 'hendrawijaya', '081200000108'),
(109, 3, 1, 'Staff', 'Ismi Fadilah', 'ismifadilah', '081200000109'),
(110, 3, 6, 'Staff', 'Jaka Suranta', 'jakasuranta', '081200000110'),
(111, 4, 1, 'Staff', 'Kania Ayu', 'kaniaayu', '081200000111'),
(112, 5, 1, 'Staff', 'Lukman Hakim', 'lukmanhakim', '081200000112'),
(113, 6, 1, 'Staff', 'Mira Juita', 'mirajuita', '081200000113'),
(114, 7, 1, 'Staff', 'Noval Ardian', 'novalardian', '081200000114'),
(115, 8, 1, 'Staff', 'Ogi Firdaus', 'ogifirdaus', '081200000115'),
(116, 9, 1, 'Staff', 'Putri Setiana', 'putrisetiana', '081200000116'),
(117, 10, 1, 'Staff', 'Qadir Husaini', 'qadirhusaini', '081200000117'),
(118, 11, 1, 'Staff', 'Ria Susanti', 'riasusanti', '081200000118'),
(119, 11, 2, 'Staff', 'Seto Nugraha', 'setonugraha', '081200000119'),
(120, 11, 3, 'Staff', 'Tria Putri', 'triaputri', '081200000120'),
(121, 12, 1, 'Staff', 'Ujang Permana', 'ujangpermana', '081200000121'),
(122, 13, 1, 'Staff', 'Vira Juanita', 'virajuanita', '081200000122'),
(123, 14, 1, 'Staff', 'Wangi Kusuma', 'wangikusuma', '081200000123'),
(124, 15, 1, 'Staff', 'Xandra Halim', 'xandrahalim', '081200000124'),
(125, 16, 1, 'Staff', 'Yanda Pratama', 'yandapratama', '081200000125');

-- ------------------------------------------------------------
-- 9. DATA SUB-ROLE (MAHASISWA, DOSEN, STAFF)
-- ------------------------------------------------------------
INSERT INTO mahasiswa (idPengguna, NIM) VALUES 
(1, '10231001'), (2, '10231002'), (3, '10231003'), (4, '10231004'), (5, '10231005'),
(6, '10231006'), (7, '10231007'), (8, '10231008'), (9, '10231009'), (10, '10231010'),
(21, '10231021'), (22, '10231022'), (23, '10231023'), (24, '10231024'), (25, '10231025'),
(26, '10231026'), (31, '10231031'), (32, '10231032'), (33, '10231033'), (34, '10231034'),
(38, '10231038'), (39, '10231039'), (41, '10231041'), (42, '10231042'), (44, '10231044'),
(45, '10231045'), (47, '10231047'), (49, '10231049'), (50, '10231050'), (52, '10231052'),
(53, '10231053'), (55, '10231055'), (57, '10231057'), (58, '10231058'), (59, '10231059'),
(60, '10231060'), (65, '10231065'), (66, '10231066'), (68, '10231068'), (69, '10231069'),
(71, '10231071'), (73, '10231073'), (74, '10231074'), (76, '10231076'), (77, '10231077'),
(81, '10231081'), (82, '10231082'), (83, '10231083'), (85, '10231085'), (86, '10231086'),
(88, '10231088'), (89, '10231089'), (91, '10231091'), (92, '10231092'), (94, '10231094'),
(96, '10231096'), (97, '10231097'), (99, '10231099');

INSERT INTO dosen (idPengguna, NIP) VALUES 
(11, '198001011001'), (12, '198001011002'), (13, '197001011003'), (14, '198001011004'), (15, '196501011005'),
(27, '198501012001'), (28, '198501012002'), (29, '196501012003'), (35, '197801013001'), (36, '198201013002'),
(40, '196801014001'), (43, '197501015001'), (46, '198001016001'), (48, '196001017001'), (51, '197801018001'),
(54, '196801019001'), (56, '197501020001'), (61, '196001021001'), (62, '198001022001'), (63, '196501023001'),
(67, '197801024001'), (70, '196001025001'), (72, '198201026001'), (75, '196001027001'), (78, '197801028001'),
(79, '196501029001'), (84, '198001030001'), (87, '196001031001'), (90, '197501032001'), (93, '196001033001'),
(95, '197501034001'), (98, '196001035001'), (100, '197501036001'), (65, '197001036003')
ON DUPLICATE KEY UPDATE NIP = VALUES(NIP);

INSERT INTO staff (idPengguna, NIK, bidangStaff) VALUES 
(16, '3271010101800001', 'Administrasi Akademik'), (17, '3271010101800002', 'Teknisi Lab'),
(18, '3271010101800003', 'Keuangan'), (19, '3271010101800004', 'Keamanan'),
(20, '3271010101800005', 'Kebersihan'), (30, '3272010101800006', 'Administrasi Akademik'),
(37, '3273010101800007', 'Teknisi Lab'), (64, '3271010101800008', 'Keuangan'),
(80, '3274010101800009', 'Administrasi Akademik'), (101, '3271010101800101', 'Administrasi Akademik'),
(102, '3271010101800102', 'Teknisi Lab'), (103, '3271010101800103', 'Keuangan'),
(104, '3271010101800104', 'Keamanan'), (105, '3271010101800105', 'Kebersihan'),
(106, '3272010101800106', 'Administrasi Akademik'), (107, '3272010101800107', 'Teknisi Lab'),
(108, '3272010101800108', 'Keuangan'), (109, '3273010101800109', 'Keamanan'),
(110, '3273010101800110', 'Kebersihan'), (111, '3274010101800111', 'Administrasi Akademik'),
(112, '3275010101800112', 'Teknisi Lab'), (113, '3276010101800113', 'Keuangan'),
(114, '3277010101800114', 'Keamanan'), (115, '3278010101800115', 'Kebersihan'),
(116, '3279010101800116', 'Administrasi Akademik'), (117, '3280010101800117', 'Teknisi Lab'),
(118, '3271010101800118', 'Keuangan'), (119, '3271010101800119', 'Keamanan'),
(120, '3271010101800120', 'Kebersihan'), (121, '3272010101800121', 'Administrasi Akademik'),
(122, '3273010101800122', 'Teknisi Lab'), (123, '3274010101800123', 'Keuangan'),
(124, '3275010101800124', 'Keamanan'), (125, '3276010101800125', 'Kebersihan')
ON DUPLICATE KEY UPDATE bidangStaff = VALUES(bidangStaff);

-- ------------------------------------------------------------
-- 10. DATA ROLE ADMIN
-- ------------------------------------------------------------
INSERT INTO roleAdmin (idAdmin, idPengguna, idGedung, idFakultas, namaRole, levelAkses) VALUES 
(1, 16, 1, 1, 'Admin Gedung Teknik A', 2),
(2, 17, 2, 2, 'Admin Gedung Ilmu Komputer B', 2),
(3, 18, 3, 3, 'Admin Gedung Ekonomi C', 2),
(4, 19, 4, 4, 'Admin Gedung Hukum D', 2),
(5, 20, 5, 5, 'Admin Gedung Kedokteran E', 2),
(6, 30, 8, 1, 'Admin Gedung Cimahi A', 2),
(7, 37, 11, 1, 'Admin Gedung Sumedang A', 2),
(8, 64, 30, 1, 'Admin Gedung Jakarta A', 2),
(9, 80, 45, 1, 'Admin Gedung Surabaya A', 2),
(10, 101, 6, NULL, 'Admin Rektorat', 3),
(11, 102, 7, NULL, 'Admin Gedung Serbaguna', 3),
(12, 103, NULL, 1, 'Admin Fakultas Teknik', 3),
(13, 104, NULL, 2, 'Admin Fakultas Ilmu Komputer', 3),
(14, 105, NULL, 3, 'Admin Fakultas Ekonomi', 3),
(15, 106, 9, 2, 'Admin Gedung IK Cimahi', 2),
(16, 107, 10, NULL, 'Admin Serbaguna Cimahi', 2),
(17, 108, 12, NULL, 'Admin Umum Sumedang', 2),
(18, 109, 13, 1, 'Admin Gedung Garut A', 2),
(19, 110, 15, NULL, 'Admin Serbaguna Garut', 2),
(20, 111, 16, 1, 'Admin Gedung Tasik A', 2),
(21, 112, 18, NULL, 'Admin Serbaguna Tasik', 2),
(22, 113, 19, 1, 'Admin Gedung Majalengka A', 2),
(23, 114, 21, 1, 'Admin Gedung Cianjur A', 2),
(24, 115, 23, 1, 'Admin Gedung Purwakarta A', 2),
(25, 116, 26, 1, 'Admin Gedung Karawang A', 2),
(26, 117, 28, 1, 'Admin Gedung Subang A', 2),
(27, 118, 31, 2, 'Admin Gedung IK Jakarta', 2),
(28, 119, 32, 3, 'Admin Gedung Ekonomi Jakarta', 2),
(29, 120, 33, NULL, 'Admin Serbaguna Jakarta', 2),
(30, 121, 34, 1, 'Admin Gedung Depok A', 2),
(31, 122, 37, 1, 'Admin Gedung Bekasi A', 2),
(32, 123, 40, 1, 'Admin Gedung Tangerang A', 2),
(33, 124, 42, 1, 'Admin Gedung Bogor A', 2),
(34, 125, NULL, 4, 'Admin Fakultas Hukum', 3),
(35, 64, NULL, 5, 'Admin Fakultas Kedokteran', 3),
(36, 80, 46, 5, 'Admin Gedung Kedokteran Sby', 2),
(37, 101, 47, 2, 'Admin Gedung IK Surabaya', 2),
(38, 102, 48, NULL, 'Admin Serbaguna Surabaya', 2),
(39, 103, 54, 1, 'Admin Gedung Teknik Yogya', 2),
(40, 104, 55, 5, 'Admin Gedung Kedokteran Yogya', 2);

-- ------------------------------------------------------------
-- 11. DATA PEMINJAMAN
-- ------------------------------------------------------------
INSERT INTO peminjaman (idPeminjaman, idPengguna, tujuanPeminjaman, waktuPengajuan, suratPeminjaman, statusPeminjaman) VALUES 
(1, 1, 'Rapat Himpunan Mahasiswa Teknik', '2025-01-05 08:00:00', 'surat_001.pdf', 'Disetujui'),
(2, 3, 'Seminar Kecerdasan Buatan', '2025-01-06 09:00:00', 'surat_002.pdf', 'Disetujui'),
(3, 5, 'Workshop Kewirausahaan', '2025-01-07 10:00:00', 'surat_003.pdf', 'Disetujui'),
(4, 7, 'Diskusi Kelompok Hukum Perdata', '2025-01-08 08:30:00', 'surat_004.pdf', 'Disetujui'),
(5, 9, 'Simulasi OSCE Kedokteran', '2025-01-09 09:00:00', 'surat_005.pdf', 'Disetujui'),
(6, 2, 'Praktikum Jaringan Komputer', '2025-01-10 08:00:00', 'surat_006.pdf', 'Disetujui'),
(7, 4, 'Belajar Bareng Pemrograman Web', '2025-01-11 10:00:00', 'surat_007.pdf', 'Disetujui'),
(8, 6, 'Presentasi Bisnis Plan', '2025-01-12 08:00:00', 'surat_008.pdf', 'Disetujui'),
(9, 8, 'Moot Court Simulasi Sidang', '2025-01-13 09:00:00', 'surat_009.pdf', 'Disetujui'),
(10, 10, 'Diskusi Kelompok Anatomi', '2025-01-14 10:00:00', 'surat_010.pdf', 'Disetujui'),
(11, 21, 'Rapat BEM Cimahi', '2025-01-15 08:00:00', 'surat_011.pdf', 'Disetujui'),
(12, 22, 'Hackathon Mini Cimahi', '2025-01-16 09:00:00', 'surat_012.pdf', 'Disetujui'),
(13, 25, 'Seminar Ekonomi Digital', '2025-01-17 10:00:00', 'surat_013.pdf', 'Disetujui'),
(14, 31, 'Workshop IoT', '2025-01-18 08:00:00', 'surat_014.pdf', 'Disetujui'),
(15, 33, 'Seminar Farmasi Klinis', '2025-01-19 09:00:00', 'surat_015.pdf', 'Disetujui'),
(16, 38, 'Diskusi Teknik Sipil', '2025-01-20 10:00:00', 'surat_016.pdf', 'Disetujui'),
(17, 41, 'Rapat HMTE Tasikmalaya', '2025-01-21 08:00:00', 'surat_017.pdf', 'Disetujui'),
(18, 44, 'Kuliah Umum Keteknikan', '2025-01-22 09:00:00', 'surat_018.pdf', 'Disetujui'),
(19, 47, 'Workshop Desain Grafis', '2025-01-23 10:00:00', 'surat_019.pdf', 'Disetujui'),
(20, 49, 'Seminar Robotika', '2025-01-24 08:00:00', 'surat_020.pdf', 'Disetujui'),
(21, 52, 'Rapat HMM Karawang', '2025-01-25 09:00:00', 'surat_021.pdf', 'Disetujui'),
(22, 57, 'Seminar AI Jakarta', '2025-01-26 10:00:00', 'surat_022.pdf', 'Disetujui'),
(23, 59, 'Workshop Data Science', '2025-01-27 08:00:00', 'surat_023.pdf', 'Disetujui'),
(24, 65, 'Presentasi Tugas Besar', '2025-01-28 09:00:00', 'surat_024.pdf', 'Disetujui'),
(25, 66, 'Diskusi Kelompok Psikologi', '2025-01-29 10:00:00', 'surat_025.pdf', 'Disetujui'),
(26, 68, 'Seminar Hukum Bisnis', '2025-02-01 08:00:00', 'surat_026.pdf', 'Disetujui'),
(27, 71, 'Rapat Himpunan Teknik Tangerang', '2025-02-02 09:00:00', 'surat_027.pdf', 'Disetujui'),
(28, 73, 'Workshop Agrikultur Bogor', '2025-02-03 10:00:00', 'surat_028.pdf', 'Disetujui'),
(29, 76, 'Rapat Senat Mahasiswa Surabaya', '2025-02-04 08:00:00', 'surat_029.pdf', 'Disetujui'),
(30, 77, 'Diskusi Kedokteran Klinis', '2025-02-05 09:00:00', 'surat_030.pdf', 'Disetujui'),
(31, 81, 'Workshop Machine Learning Yogya', '2025-02-06 10:00:00', 'surat_031.pdf', 'Disetujui'),
(32, 83, 'Seminar Sistem Informasi Yogya', '2025-02-07 08:00:00', 'surat_032.pdf', 'Disetujui'),
(33, 85, 'Rapat Himpunan Teknik Semarang', '2025-02-08 09:00:00', 'surat_033.pdf', 'Disetujui'),
(34, 88, 'Seminar Teknologi Informasi Medan', '2025-02-09 10:00:00', 'surat_034.pdf', 'Disetujui'),
(35, 91, 'Workshop Teknik Industri Makassar', '2025-02-10 08:00:00', 'surat_035.pdf', 'Disetujui'),
(36, 94, 'Rapat HMP Padang', '2025-02-11 09:00:00', 'surat_036.pdf', 'Disetujui'),
(37, 96, 'Seminar Bisnis Palembang', '2025-02-12 10:00:00', 'surat_037.pdf', 'Disetujui'),
(38, 99, 'Rapat BEM Pontianak', '2025-02-13 08:00:00', 'surat_038.pdf', 'Disetujui'),
(39, 1, 'Kuliah Umum Energi Terbarukan', '2025-02-14 09:00:00', 'surat_039.pdf', 'Menunggu'),
(40, 2, 'Seminar Keamanan Jaringan', '2025-02-15 10:00:00', 'surat_040.pdf', 'Menunggu'),
(41, 5, 'Diskusi Patologi Klinik', '2025-02-16 08:00:00', 'surat_041.pdf', 'Menunggu'),
(42, 10, 'Presentasi Riset Kedokteran', '2025-02-17 09:00:00', 'surat_042.pdf', 'Menunggu'),
(43, 3, 'Seminar Ekonomi Syariah', '2025-02-18 10:00:00', 'surat_043.pdf', 'Ditolak'),
(44, 7, 'Diskusi Hukum Tata Negara', '2025-02-19 08:00:00', 'surat_044.pdf', 'Ditolak'),
(45, 21, 'Workshop Embedded System', '2025-02-20 09:00:00', 'surat_045.pdf', 'Menunggu');

-- ------------------------------------------------------------
-- 12. DATA DETAIL PEMINJAMAN
-- ------------------------------------------------------------
INSERT INTO detailPeminjaman (idDetailPeminjaman, idPeminjaman, idRuangan, tanggalPeminjaman, waktuPeminjaman, waktuSelesai, tanggalSelesai) VALUES 
(1, 1, 26, '2025-01-10', '09:00:00', '11:00:00', '2025-01-10'),
(2, 2, 7, '2025-01-10', '13:00:00', '17:00:00', '2025-01-10'),
(3, 3, 29, '2025-01-11', '08:00:00', '12:00:00', '2025-01-11'),
(4, 4, 18, '2025-01-11', '13:00:00', '15:00:00', '2025-01-11'),
(5, 5, 23, '2025-01-12', '08:00:00', '11:00:00', '2025-01-12'),
(6, 6, 5, '2025-01-13', '09:00:00', '12:00:00', '2025-01-13'),
(7, 7, 12, '2025-01-14', '10:00:00', '14:00:00', '2025-01-14'),
(8, 8, 17, '2025-01-15', '08:00:00', '10:00:00', '2025-01-15'),
(9, 9, 21, '2025-01-16', '13:00:00', '17:00:00', '2025-01-16'),
(10, 10, 24, '2025-01-17', '09:00:00', '12:00:00', '2025-01-17'),
(11, 11, 30, '2025-01-18', '08:00:00', '11:00:00', '2025-01-18'),
(12, 12, 34, '2025-01-19', '09:00:00', '13:00:00', '2025-01-19'),
(13, 13, 17, '2025-01-20', '10:00:00', '14:00:00', '2025-01-20'),
(14, 14, 32, '2025-01-21', '08:00:00', '12:00:00', '2025-01-21'),
(15, 15, 43, '2025-01-22', '09:00:00', '13:00:00', '2025-01-22'),
(16, 16, 36, '2025-01-23', '10:00:00', '14:00:00', '2025-01-23'),
(17, 17, 42, '2025-01-24', '08:00:00', '11:00:00', '2025-01-24'),
(18, 18, 44, '2025-01-25', '09:00:00', '12:00:00', '2025-01-25'),
(19, 19, 27, '2025-01-26', '10:00:00', '14:00:00', '2025-01-26'),
(20, 20, 28, '2025-01-27', '08:00:00', '12:00:00', '2025-01-27'),
(21, 21, 30, '2025-01-28', '09:00:00', '12:00:00', '2025-01-28'),
(22, 22, 45, '2025-01-29', '10:00:00', '14:00:00', '2025-01-29'),
(23, 23, 48, '2025-01-30', '08:00:00', '12:00:00', '2025-01-30'),
(24, 24, 9, '2025-01-31', '09:00:00', '13:00:00', '2025-01-31'),
(25, 25, 86, '2025-02-01', '10:00:00', '13:00:00', '2025-02-01'),
(26, 26, 19, '2025-02-03', '08:00:00', '11:00:00', '2025-02-03'),
(27, 27, 31, '2025-02-04', '09:00:00', '12:00:00', '2025-02-04'),
(28, 28, 88, '2025-02-05', '10:00:00', '14:00:00', '2025-02-05'),
(29, 29, 51, '2025-02-06', '08:00:00', '12:00:00', '2025-02-06'),
(30, 30, 54, '2025-02-07', '09:00:00', '13:00:00', '2025-02-07'),
(31, 31, 58, '2025-02-08', '10:00:00', '14:00:00', '2025-02-08'),
(32, 32, 61, '2025-02-09', '08:00:00', '12:00:00', '2025-02-09'),
(33, 33, 63, '2025-02-10', '09:00:00', '13:00:00', '2025-02-10'),
(34, 34, 66, '2025-02-11', '10:00:00', '14:00:00', '2025-02-11'),
(35, 35, 70, '2025-02-12', '08:00:00', '12:00:00', '2025-02-12'),
(36, 36, 74, '2025-02-13', '09:00:00', '13:00:00', '2025-02-13'),
(37, 37, 50, '2025-02-14', '10:00:00', '14:00:00', '2025-02-14'),
(38, 38, 77, '2025-02-15', '08:00:00', '12:00:00', '2025-02-15'),
(39, 39, 8, '2025-02-20', '09:00:00', '17:00:00', '2025-02-20'),
(40, 40, 6, '2025-02-21', '10:00:00', '14:00:00', '2025-02-21'),
(41, 41, 24, '2025-02-22', '08:00:00', '11:00:00', '2025-02-22'),
(42, 42, 25, '2025-02-23', '09:00:00', '12:00:00', '2025-02-23'),
(43, 43, 15, '2025-02-25', '10:00:00', '12:00:00', '2025-02-25'),
(44, 44, 20, '2025-02-26', '08:00:00', '10:00:00', '2025-02-26'),
(45, 45, 33, '2025-02-27', '09:00:00', '13:00:00', '2025-02-27');

-- ------------------------------------------------------------
-- 13. DATA PERSETUJUAN
-- ------------------------------------------------------------
INSERT INTO persetujuan (idPersetujuan, idDetailPeminjaman, idAdmin, waktuPersetujuan, statusPersetujuan) VALUES 
(1, 1, 10, '2025-01-07 10:00:00', 'Disetujui'),
(2, 2, 1, '2025-01-07 10:05:00', 'Disetujui'),
(3, 3, 11, '2025-01-08 09:00:00', 'Disetujui'),
(4, 4, 3, '2025-01-08 09:10:00', 'Disetujui'),
(5, 5, 5, '2025-01-09 09:00:00', 'Disetujui'),
(6, 6, 1, '2025-01-10 09:00:00', 'Disetujui'),
(7, 7, 2, '2025-01-10 09:30:00', 'Disetujui'),
(8, 8, 14, '2025-01-11 09:00:00', 'Disetujui'),
(9, 9, 4, '2025-01-11 09:30:00', 'Disetujui'),
(10, 10, 5, '2025-01-12 09:00:00', 'Disetujui'),
(11, 11, 6, '2025-01-13 09:00:00', 'Disetujui'),
(12, 12, 15, '2025-01-14 09:00:00', 'Disetujui'),
(13, 13, 14, '2025-01-15 09:00:00', 'Disetujui'),
(14, 14, 6, '2025-01-16 09:00:00', 'Disetujui'),
(15, 15, 20, '2025-01-17 09:00:00', 'Disetujui'),
(16, 16, 7, '2025-01-18 09:00:00', 'Disetujui'),
(17, 17, 20, '2025-01-19 09:00:00', 'Disetujui'),
(18, 18, 21, '2025-01-20 09:00:00', 'Disetujui'),
(19, 19, 10, '2025-01-21 09:00:00', 'Disetujui'),
(20, 20, 11, '2025-01-22 09:00:00', 'Disetujui'),
(21, 21, 6, '2025-01-23 09:00:00', 'Disetujui'),
(22, 22, 8, '2025-01-24 09:00:00', 'Disetujui'),
(23, 23, 8, '2025-01-25 09:00:00', 'Disetujui'),
(24, 24, 2, '2025-01-26 09:00:00', 'Disetujui'),
(25, 25, 13, '2025-01-27 09:00:00', 'Disetujui'),
(26, 26, 7, '2025-01-28 09:00:00', 'Disetujui'),
(27, 27, 16, '2025-01-29 09:00:00', 'Disetujui'),
(28, 28, 33, '2025-01-30 09:00:00', 'Disetujui'),
(29, 29, 29, '2025-01-31 09:00:00', 'Disetujui'),
(30, 30, 9, '2025-02-01 09:00:00', 'Disetujui'),
(31, 31, 39, '2025-02-02 09:00:00', 'Disetujui'),
(32, 32, 39, '2025-02-03 09:00:00', 'Disetujui'),
(33, 33, 12, '2025-02-04 09:00:00', 'Disetujui'),
(34, 34, 12, '2025-02-05 09:00:00', 'Disetujui'),
(35, 35, 37, '2025-02-06 09:00:00', 'Disetujui'),
(36, 36, 9, '2025-02-07 09:00:00', 'Disetujui'),
(37, 37, 28, '2025-02-08 09:00:00', 'Disetujui'),
(38, 38, 37, '2025-02-09 09:00:00', 'Disetujui'),
(39, 43, 3, '2025-02-19 09:00:00', 'Ditolak'),
(40, 44, 4, '2025-02-19 09:30:00', 'Ditolak');

/* === PENAMBAHAN ISI DATABASE TAMBAHAN === */

/* =====================================================================
   1. gedungUmum  -> semua gedung yang idFakultas-nya NULL
   ===================================================================== */
INSERT INTO gedungUmum (idGedung)
SELECT idGedung
FROM gedung
WHERE idFakultas IS NULL
  AND idGedung NOT IN (SELECT idGedung FROM gedungUmum);

/* =====================================================================
   2. gedungKhusus -> semua gedung yang punya idFakultas
   ===================================================================== */
INSERT INTO gedungKhusus (idGedung, idFakultas)
SELECT idGedung, idFakultas
FROM gedung
WHERE idFakultas IS NOT NULL
  AND idGedung NOT IN (SELECT idGedung FROM gedungKhusus);

/* =====================================================================
   3. detailAdminGdg -> admin yang terikat ke gedung tertentu
   ===================================================================== */
INSERT IGNORE INTO detailAdminGdg (idGedung, idAdmin)
SELECT idGedung, idAdmin
FROM roleAdmin
WHERE idGedung IS NOT NULL;

/* Admin tingkat fakultas (idGedung NULL, idFakultas terisi) mengelola
   semua gedung milik fakultasnya */
INSERT IGNORE INTO detailAdminGdg (idGedung, idAdmin)
SELECT g.idGedung, ra.idAdmin
FROM roleAdmin ra
JOIN gedung g ON g.idFakultas = ra.idFakultas
WHERE ra.idGedung IS NULL
  AND ra.idFakultas IS NOT NULL;

/* =====================================================================
   4. detailAdminFkt -> admin yang terikat ke fakultas tertentu
   ===================================================================== */
INSERT IGNORE INTO detailAdminFkt (idFakultas, idAdmin)
SELECT idFakultas, idAdmin
FROM roleAdmin
WHERE idFakultas IS NOT NULL;

/* =====================================================================
   5. detailFasilitas -> lengkapi ruangan yang belum punya fasilitas
      (INSERT IGNORE: baris lama tidak ditimpa / tidak error)
      jumlah = -1 artinya "sebanyak kapasitas ruangan"
   ===================================================================== */
INSERT IGNORE INTO detailFasilitas (idFasilitas, idRuangan, jumlahFasilitas)
SELECT m.idFasilitas, r.idRuangan, IF(m.jumlah = -1, r.kapasitas, m.jumlah)
FROM ruangan r
JOIN (
    /* Kelas */
    SELECT 'Kelas' AS kategori, 1 AS idFasilitas, 1 AS jumlah
    UNION ALL SELECT 'Kelas', 2, 2
    UNION ALL SELECT 'Kelas', 3, 1
    UNION ALL SELECT 'Kelas', 6, -1
    UNION ALL SELECT 'Kelas', 36, 1
    UNION ALL SELECT 'Kelas', 37, 1
    /* Laboratorium */
    UNION ALL SELECT 'Laboratorium', 3, 1
    UNION ALL SELECT 'Laboratorium', 5, -1
    UNION ALL SELECT 'Laboratorium', 6, -1
    UNION ALL SELECT 'Laboratorium', 19, 10
    UNION ALL SELECT 'Laboratorium', 20, 1
    /* Seminar */
    UNION ALL SELECT 'Seminar', 1, 2
    UNION ALL SELECT 'Seminar', 3, 2
    UNION ALL SELECT 'Seminar', 6, -1
    UNION ALL SELECT 'Seminar', 8, 2
    UNION ALL SELECT 'Seminar', 9, 2
    UNION ALL SELECT 'Seminar', 10, 2
    /* Aula */
    UNION ALL SELECT 'Aula', 1, 4
    UNION ALL SELECT 'Aula', 3, 4
    UNION ALL SELECT 'Aula', 6, -1
    UNION ALL SELECT 'Aula', 8, 4
    UNION ALL SELECT 'Aula', 9, 4
    UNION ALL SELECT 'Aula', 61, 1
    /* Rapat */
    UNION ALL SELECT 'Rapat', 3, 1
    UNION ALL SELECT 'Rapat', 13, 1
    UNION ALL SELECT 'Rapat', 41, 1
    UNION ALL SELECT 'Rapat', 42, -1
    UNION ALL SELECT 'Rapat', 48, 1
) m ON m.kategori = r.kategoriRuangan;

