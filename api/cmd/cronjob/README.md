# Log Cleanup Cronjob

Sistem cronjob untuk membersihkan file-file log (.log) secara otomatis dari direktori `api/logger` setiap bulan.

## File-file yang Tersedia

### 1. `log_cleanup.go`
Script utama yang bertugas untuk:
- Mencari semua file dengan ekstensi `.log` di direktori `api/logger`
- Menghapus file-file tersebut
- Mencatat aktivitas pembersihan ke `cleanup_history.log`
- Menampilkan summary jumlah file yang dihapus dan space yang dibebaskan

### 2. `cron_config.sh` (Linux/macOS)
Script untuk mengkonfigurasi cron job di sistem Linux/macOS:
- Menjalankan pembersihan setiap tanggal 1 di jam 2:00 pagi
- Menyimpan log output ke `cron_cleanup.log`

### 3. `cron_config.bat` (Windows)
Script untuk mengkonfigurasi scheduled task di Windows:
- Menjalankan pembersihan setiap tanggal 1 di jam 2:00 pagi
- Menyimpan log output ke `cron_cleanup.log`

## Cara Penggunaan

### Linux/macOS
```bash
# Masuk ke direktori cronjob
cd api/cmd/cronjob

# Berikan permission execute
chmod +x cron_config.sh

# Jalankan script konfigurasi
./cron_config.sh

# Verifikasi cron job
crontab -l
```

### Windows
```cmd
# Masuk ke direktori cronjob
cd api\cmd\cronjob

# Jalankan sebagai Administrator
cron_config.bat

# Verifikasi scheduled task
schtasks /query /tn "LogCleanupMonthly"
```

## Eksekusi Manual

Untuk menjalankan pembersihan log secara manual:

```bash
# Linux/macOS/Windows
cd api/cmd/cronjob
go run log_cleanup.go
```

## Jadwal Eksekusi

- **Frekuensi**: Setiap bulan
- **Tanggal**: Tanggal 1
- **Waktu**: 02:00 (2:00 AM)
- **Target**: Semua file `.log` di direktori `api/logger`

## Log Files

1. **`cleanup_history.log`**: Menyimpan riwayat aktivitas pembersihan
2. **`cron_cleanup.log`**: Menyimpan output dari eksekusi cron job/scheduled task

## Keamanan

- Script hanya menghapus file dengan ekstensi `.log`
- Membuat backup riwayat pembersihan di `cleanup_history.log`
- Menampilkan summary sebelum dan sesudah pembersihan
- Error handling untuk file yang tidak bisa dihapus

## Troubleshooting

### Cron job tidak berjalan (Linux/macOS)
```bash
# Cek status cron service
sudo systemctl status cron

# Cek log cron
sudo tail -f /var/log/cron.log
```

### Scheduled task tidak berjalan (Windows)
```cmd
# Cek status task
schtasks /query /tn "LogCleanupMonthly" /v

# Cek event log
eventvwr.msc
```

### Permission denied
- Linux/macOS: Pastikan user memiliki permission untuk menulis di direktori logger
- Windows: Jalankan script konfigurasi sebagai Administrator