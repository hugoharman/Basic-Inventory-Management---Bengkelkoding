# mobile_inventory_system_local

Basic Inventory Management

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

# Basic Inventory Management

Aplikasi berfokus pada manajemen inventaris barang dengan fitur utama:

## **Input Data Barang**

- **Informasi barang**: nama, deskripsi, harga, dan kategori.
- **Foto barang** menggunakan kamera atau galeri.

## **Riwayat Barang**

- Pencatatan transaksi **barang masuk** dan **barang keluar**, termasuk tanggal dan jumlah transaksi.
- Laporan ringkasan stok yang dihasilkan berdasarkan riwayat transaksi.

## **Penyimpanan Data Lokal**

- Semua data barang, stok, dan riwayat transaksi disimpan secara lokal menggunakan SQLite.

## **Antarmuka Pengguna**

- Desain ramah pengguna untuk mempermudah proses pencatatan dan manajemen inventaris.

## Tampilan yang Diperlukan

### 1. Halaman Daftar Barang

#### Fungsi

- Menampilkan daftar semua barang yang tersimpan.

#### Konten

- Nama barang, foto, kategori, harga, dan jumlah stok saat ini.
- Tombol untuk menambah barang baru.
- Tombol aksi untuk melihat detail barang.

#### Aksi

- Navigasi ke halaman detail barang.
- Navigasi ke halaman tambah barang.

### 2. Halaman Tambah Barang

#### Fungsi

- Input data barang baru.

#### Konten

- Form input (nama barang, deskripsi, kategori, harga).
- Pilihan untuk mengambil foto dari kamera atau galeri.

#### Aksi

- Menyimpan data barang ke SQLite & menyimpan foto ke direktori tertentu.
- Kembali ke halaman daftar barang.

### 3. Halaman Detail Barang

#### Fungsi

- Menampilkan informasi barang dan memungkinkan pencatatan riwayat stok.

#### Konten

- Informasi barang (nama, deskripsi, harga, stok, dan gambar barang).
- Daftar riwayat barang masuk dan keluar.
- Tombol untuk menambah riwayat barang masuk atau keluar.

#### Aksi

- Navigasi ke halaman tambah riwayat.
- Menghapus atau memperbarui data barang.

### 4. Halaman Tambah Riwayat Barang

#### Fungsi

- Mencatat barang masuk atau keluar.

#### Konten

- Form input (jenis transaksi: masuk/keluar, jumlah, tanggal).

#### Aksi

- Menyimpan riwayat transaksi ke SQLite.
- Memperbarui stok barang berdasarkan riwayat transaksi.
