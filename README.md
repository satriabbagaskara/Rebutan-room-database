# Rebutan.room — Campus Room Reservation & Management Database

**Rebutan.room** adalah rancangan sistem basis data relasional (RDBMS) komprehensif yang dirancang untuk mengelola ketersediaan, peminjaman, serta reservasi ruangan di lingkungan kampus multi-cabang dan multi-fakultas.

Sistem ini memungkinkan pengguna (Mahasiswa, Dosen, Staff) untuk mengajukan peminjaman ruangan yang terintegrasi dengan hierarki persetujuan berbasis peran (*Role-Based Admin Approval*).

Proyek ini disusun sebagai Tugas Besar Mata Kuliah Pemodelan Basis Data (PBD) - Telkom University.

---

## 📌 Cakupan Skema & Arsitektur Data

Basis data dirancang menggunakan **HeidiSQL / MySQL** dengan mencakup 19 tabel terelasi:
* **Entitas Kampus & Fasilitas**: `kampus`, `cabang`, `fakultas`, `gedung`, `gedungUmum`, `gedungKhusus`, `ruangan`, `fasilitas`, `detailFasilitas`.
* **Entitas Pengguna & Hak Akses**: `pengguna`, `mahasiswa`, `dosen`, `staff`, `roleAdmin`, `detailAdminFkt`, `detailAdminGdg`.
* **Entitas Transaksi Peminjaman**: `peminjaman`, `detailPeminjaman`, `persetujuan`.

---

## 🛠️ Tech Stack & Fitur SQL

* **DBMS**: MySQL / MariaDB (HeidiSQL)
* **Fitur & Teknik SQL yang Diimplementasikan**:
  * **DDL (Data Definition Language)**: Penggunaan *Primary Key*, *Foreign Key Constraints*, dan relasi antar tabel (1:N, N:M).
  * **DML (Data Manipulation Language)**: Penyisipan dataset uji (*seed data*) komprehensif.
  * **Complex Queries & Analytics**:
    * Relasi multi-tabel (`INNER JOIN`, `LEFT JOIN`).
    * Fungsi agregasi (`COUNT`, `AVG`) & Pengelompokan (`GROUP BY`).
    * Analisis filter tingkat lanjut menggunakan `HAVING` dengan *Subquery*.
    * Pengurutan data (`ORDER BY`) dan penyaringan kondisional (`WHERE`).

---

## 📊 Contoh Query Analitis (Studi Kasus)

Repositori ini memuat 6 studi kasus query analitis (dapat dilihat di `analytical_queries.sql`), antara lain:
1. **Pencarian Ruangan menurut Kapasitas Gedung Tinggi**: Menampilkan ruangan di gedung dengan jumlah lantai $\ge 5$.
2. **Rekap Peran Pengguna**: Menggabungkan data mahasiswa, dosen, dan staff menggunakan `LEFT JOIN`.
3. **Analisis Pengaju Peminjaman Aktif**: Mengidentifikasi pengguna dengan total pengajuan di atas rata-rata menggunakan `HAVING` dan *Subquery*.
4. **Distribusi Ruangan per Gedung**: Menghitung akumulasi jumlah ruangan di setiap gedung kampus.

---

## 🚀 Cara Menggunakan

1. Buka lingkungan MySQL / MariaDB / HeidiSQL Anda.
2. Impor dan jalankan berkas `schema_and_data.sql` untuk membuat basis data `rebutan_room` beserta data awalnya:
   ```sql
   SOURCE schema_and_data.sql;
