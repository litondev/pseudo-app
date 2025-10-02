# Docker Setup untuk Pseudo App

## Deskripsi

Docker Compose setup untuk menjalankan aplikasi Pseudo App yang terdiri dari:
- **API**: Go Fiber application (Port 8000)
- **MySQL**: Database server (Port 3306)
- **PhpMyAdmin**: Database management tool (Port 8080)

## Persyaratan

- Docker
- Docker Compose

## Struktur Services

### 1. MySQL Database
- **Image**: mysql:8.0
- **Container**: pseudo_mysql
- **Port**: 3306
- **Database**: pseudo
- **User**: pseudo_user
- **Password**: pseudo_password
- **Root Password**: root

### 2. Go API
- **Build**: Custom Dockerfile
- **Container**: pseudo_api
- **Port**: 8000
- **Environment**: Production-ready dengan health checks

### 3. PhpMyAdmin (Optional)
- **Image**: phpmyadmin/phpmyadmin:latest
- **Container**: pseudo_phpmyadmin
- **Port**: 8080
- **Access**: http://localhost:8080

## Cara Menjalankan

### 1. Build dan Start Services
```bash
# Build dan start semua services
docker-compose up --build

# Atau run di background
docker-compose up --build -d
```

### 2. Stop Services
```bash
# Stop semua services
docker-compose down

# Stop dan hapus volumes (HATI-HATI: akan menghapus data database)
docker-compose down -v
```

### 3. Restart Services
```bash
# Restart semua services
docker-compose restart

# Restart service tertentu
docker-compose restart api
docker-compose restart mysql
```

### 4. View Logs
```bash
# Lihat logs semua services
docker-compose logs

# Lihat logs service tertentu
docker-compose logs api
docker-compose logs mysql

# Follow logs real-time
docker-compose logs -f api
```

## Endpoints

### API Endpoints
- **Status**: http://localhost:8000/api/v1/status
- **Health Check**: http://localhost:8000/api/v1/health

### Database Management
- **PhpMyAdmin**: http://localhost:8080
  - Server: mysql
  - Username: root
  - Password: root

## Environment Variables

API menggunakan environment variables berikut:

```env
APP_HOST=0.0.0.0
APP_PORT=8000
APP_DEBUG=true
APP_LOGGER_LOCATION=logger/fiber.log
DB_HOST=mysql
DB_PORT=3306
DB_USER=pseudo_user
DB_PASSWORD=pseudo_password
DB_NAME=pseudo
```

## Volumes

### MySQL Data
- **Volume**: mysql_data
- **Path**: /var/lib/mysql
- **Deskripsi**: Persistent storage untuk database

### API Logs
- **Mount**: ./api/logger:/app/logger
- **Deskripsi**: Log files dari aplikasi

### API Assets
- **Mount**: ./api/asset:/app/asset
- **Deskripsi**: Static files dan uploads

### Database Initialization
- **Mount**: ./api/database/pseudo.sql:/docker-entrypoint-initdb.d/init.sql
- **Deskripsi**: SQL script untuk inisialisasi database

## Health Checks

### MySQL Health Check
```bash
mysqladmin ping -h localhost
```

### API Health Check
```bash
curl -f http://localhost:8000/api/v1/health
```

## Troubleshooting

### 1. Port Sudah Digunakan
Jika port 3306, 8000, atau 8080 sudah digunakan, ubah mapping port di docker-compose.yml:

```yaml
ports:
  - "3307:3306"  # MySQL
  - "8001:8000"  # API
  - "8081:80"    # PhpMyAdmin
```

### 2. Database Connection Error
Pastikan MySQL service sudah ready sebelum API start:
```bash
docker-compose logs mysql
```

### 3. Build Error
Hapus cache dan rebuild:
```bash
docker-compose down
docker system prune -f
docker-compose up --build --force-recreate
```

### 4. Permission Error
Pastikan folder logger dan asset memiliki permission yang benar:
```bash
chmod -R 755 api/logger api/asset
```

## Development Mode

Untuk development, bisa menggunakan volume mount untuk live reload:

```yaml
# Tambahkan di service api
volumes:
  - ./api:/app
  - /app/main  # Exclude binary
```

## Production Considerations

1. **Security**: Ganti default passwords
2. **SSL**: Tambahkan reverse proxy (nginx/traefik)
3. **Backup**: Setup automated database backup
4. **Monitoring**: Tambahkan monitoring tools
5. **Scaling**: Gunakan Docker Swarm atau Kubernetes

## Commands Berguna

```bash
# Exec ke container
docker-compose exec api sh
docker-compose exec mysql mysql -u root -p

# Backup database
docker-compose exec mysql mysqldump -u root -p pseudo > backup.sql

# Restore database
docker-compose exec -T mysql mysql -u root -p pseudo < backup.sql

# Monitor resource usage
docker stats

# Clean up
docker system prune -a
```