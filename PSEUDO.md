Api -> golang 
Api Url -> 8000 
Client -> flutter 

Step 1 : 
Check Versi Golang 
Kalau belum ada install terbaru

Check Versi Flutter 
Kalau belum ada install terbaru

Step 2 : 
Buatkan folder api untuk menampung seluruh project golang 

Buatkan folder client untuk menampung seluruh project flutter 

Step 3 : 
Buatkan init golang di folder api 

Buatkan init flutter di folder client 
folder client sebagai intinya 

Step 4 :
Buatkan Struktur Folder Di Folder Dan File Api
 - asset
  - files
   .gitignore -> file
  - images 
    - logo 
     .gitignore -> file
    - products 
     .gitignore -> file
 - cmd
  - cronjob 
 - config
 - database
 - internal
  - handlers
    - auth 
    - master
    - transaction 
  - imports
  - middlewares
  - models
  - repositories
   - auth 
   - master
   - transaction 
  - routes 
  - services
   - auth 
   - master
   - transaction
  - tests
   - auth 
   - master
   - transaction
  - docs 
  - webs
 - logger
 - pkg 
isi semua folder dengan file README.md -> isikan sesuai nama folder 

tiga file .gitignore diatas isikan
*
!default.png
!default.jpg
!default.jpeg
!README.md

Buatkan Struktur Folder Di Folder Client/Lib
 - configs
 - cores
  - utils
  - widgets
 - models
 - providers
 - screens
  - auth 
  - master
  - transaction 
 - services
isi semua folder dengan file README.md -> isikan sesuai nama folder 

Buatkan Folder Di Dalam Folder Client
 - test
  - auth 
  - master
  - transaction 
isi semua folder dengan file README.md -> isikan sesuai nama folder 

Step 5 (ABAIKAN STEP INI HARUS DILAKUKAN MANUAL):
Manual Tambahakan Logo Default Di Api 

Manual Tambahakan Product Default Di Api

Manual Tambahakan Logo Default Di Client

Step 5 :
Install Package Api Yang Terbaru Semua
- gofiber
- godotenv 
- golang-jwt
- crypto 
- gorm.io 
- gorm.io/mysql

Install Package Client Yang Terbaru Semua
- provider
- image_picker
- http 
- fl_chart
- intl 
- flutter_secure_storage
- image_picker_for_web
- printing
- file_picker
- localstorage

Step 6 : 
Buatkan file .env di folder api
Dan buatkan .env.example 
Isinya :
APP_HOST=localhost
APP_PORT=8000
APP_DEBUG=true
APP_LOGGER_LOCATION="logger/fiber.log"

DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=root
DB_NAME=pseudo

Buatkan file .env di folder client 
Dan buatkan .env.example 
Isinya :
API_URL=http://localhost:8000
API_ASSET_URL=http://localhost:8000/assets
APP_DEBUG=true

Step 7 : 
Buatkan file sql di folder api/database dlm bentuk sql 
dengan nama pseudo.sql 

Step 8 : 
Buatkan sql query untuk membuat table masukan ke dalam file pseudo.sql  

utk awalan set foreign_key_checks 0 di awal dan ubah jadi 1 di akhir

users 
 - id bigint primary key unsigned
 - name varchar(100) 
 - email varchar(100) index
 - password text
 - created_at timestamp default current_timestamp
 - updated_at timestamp default current_timestamp on update current_timestamp
 nullable semua default
buatkan data dummy juga 
salah satu data dummy gunakan 
 - email -> admin@example.com 
 - password -> 12345678 (bcrypt hash) 

warehouses
 - id bigint primary key unsigned
 - name varchar(100) index
 - created_at timestamp default current_timestamp
 - updated_at timestamp default current_timestamp on update current_timestamp
 nullable semua default
buatkan data dummy juga 

products 
 - id bigint primary key unsigned
 - name varchar(100) index
 - image varchar(100) 
 - price decimal(20,2)
 - stock decimal(20,2)
 - created_at timestamp default current_timestamp
 - updated_at timestamp default current_timestamp on update current_timestamp
 nullable semua default 
buatkan data dummy juga 
image kosongkan / dibuat null  

transactions
 - id bigintprimary key unsigned
 - user_id bigint unsigned -> berrelasi
 - product_id bigint unsigned-> berrelasi
 - warehouse_id bigintunsigned -> berrelasi
 - quantity decimal(20,2)
 - total_price decimal(20,2)
 - date timestamp default current_timestamp
 - created_at timestamp default current_timestamp
 - updated_at timestamp default current_timestamp on update current_timestamp
 - deleted_at timestamp
 nullable semua default

butakan juga modelnya di folder api/internal/models 

buatkan juga modelnya di folder client/lib/models 

pasangkan juga relasinya antara transaction dengan users, products, dan warehouses

Step 9 :
Buatkan pkg global di api/pkg  
 - hash.go 
  -> gunakan bcrypt utk hashing dan checking hashing
 - format_time.go 
  -> buatkan function yang mengembalikan flat hari bahasa indo 
  -> buatkan function yang mengembalikan map hari bahasa inggris bahasa indo cth "monday" -> "senin"
 - format_decimal
  -> buatkan function format decimal untuk mengembalikan 100000 -> 100.000,00 
  -> buatkan function format decimal untuk mengembalikan 100000.10 -> 100.000 
 - asset_folder 
  -> buatkan function yang mengembalikan nama folder images array string ["logo","products"]
 - wrap_error 
  -> buatkan warp error untuk panic recovery
Buatkan config global di api/db
 - buatakan file db.go untuk mengembalikan instance connection mysql dan hubungkan dengan .env

Buatkan main.go di folder api/cmd 
- load .env
- load db
- set debug 
- init fiber 
- panic recovery 
- setup routes 
 ini cukup 1 url dulu saja di bawah ini  
 url "/api/v1/status"
 "/api/v1" -> prefix untuk semua di bawahnya 
 "/status" -> url utama 
 return sederhana json {"message":"true"}
- script run server 

Buatkan utils global di folder client/lib/cores/utils
 - buatkan file api.dart 
    -> buatkan class untuk mempersiapkan header/body/url sebelum dikirim ke backend
     - function menambahkan header Authorization 
     - function menambahkan header Content-Type
     - tolong lengkap sendiri seluruh yang dibutuhkan atau bermanfaat
 - buatkan convertor.dart -> 
    -> buatkan class untuk memconversi data
     - function string to bool 
     - tolong lengkap sendiri seluruh yang dibutuhkan atau bermanfaat
 - buatkan format.dart
    -> buatkan class untuk memformat data
     - function format currency -> 100000 -> 100.000,00 
     - function format date -> d M YYYY
     - tolong lengkap sendiri seluruh yang dibutuhkan atau bermanfaat
 - buatkan validator.dart
   -> butakan class untuk memvalidasi data 
    - function required
    - function min length
    - function max length
    - tolong lengkap sendiri seluruh yang dibutuhkan atau bermanfaat
Buatkan widgets global di folder client/lib/cores/widgets
 - buatkan file spinner.dart 
 -> widget untuk loading icon
Buatkan configs global di folder client/lib/configs
 - buatkan file themes.dart
  - buatkan class untuk menampung segala theme style app
   - buatkan 2 theme light dan dark 
    - light : ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: const AppBarTheme(
            color: Colors.white,
            foregroundColor: Colors.black,
            iconTheme: IconThemeData(color: Colors.black),
        ),
        drawerTheme: const DrawerThemeData(
            backgroundColor: Color.fromARGB(255, 4, 63, 94),
        ),
        cardColor: Colors.white
    )
    * tambahkan custom name theme color bira nanti bisa dipanggil
    - success warna hijau
    - error warna merah

    - dark ThemeDark(
        brightness: Brightness.dark,
        primaryColor: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
        color: Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.white),
        ),
        drawerTheme: const DrawerThemeData(
        backgroundColor: Color(0xFF1E1E1E),
        ),
        cardColor: const Color(0xFF2C2C2C),
    )
    * tambahkan custom name theme color bira nanti bisa dipanggil
    - success warna hijau
    - error warna merah

 - buatkan file text_styles.dart 
   - buatkan class untuk menampung segala text style app
    - static const heading1
    - static const heading2
    - static const body 
    - static const caption  
    - tolong lengkap sendiri seluruh yang dibutuhkan atau bermanfaat
 - buatkan file platform.dart
   - buatkan class untuk menampung segala platform app 
    - string get platform 
    - static bool is web 
    - static bool is android 
    - static bool is ios 
    - static bool is windows 
    - static bool is macos 
    - static bool is linux 
    - tolong lengkap sendiri seluruh yang dibutuhkan atau bermanfaat
 - buatkan file dimension.dart
   - buatkan class untuk menampung segala dimensi app 
    - static bool is desktop 
    - static bool is tablet 
    - static bool is mobile
    - static string platform type 
    - tolong lengkap sendiri seluruh yang dibutuhkan atau bermanfaat
 - buatkan file app_size.dart
   - buatkan class untuk menampung segala ukuran app 
    - static const input height
    - static const input width 
    - static const button height
    - static const button width
    - tolong lengkap sendiri seluruh yang dibutuhkan atau bermanfaat

Step 11 : 
Buatkan docker-compose utk api dan mysql sesuai versi sekarang 
taruh docker-composer di root folder saja

Step 12 : 
Buatkan testing dan docs utk url dibawah ini 
- masukan file testing pada root folder api/internal/tests
- masukan file docs pada root folder api/internal/docs
/api/v1/status
 - unit test dan integration testing
 - docs api -> mengunakan swagger
/api/v1/health
 - unit test dan integration testing
 - docs api -> mengunakan swagger

(BLM SAMPEK SINI)
Buatkan login backend 
 - login mengunakan table users kolom email dan password
 - dengan validasi email dan password harus diisi
 - dengan jwt token 
 - dengan mengunakan hashing bcrypt (ambil dari pkg)
 - di dalam folder 
  - api/internal/models
  - api/internal/repositories/auth
  - api/internal/handlers/auth
  - api/internal/services/auth
dengan unit test dan integration test
 - di dalam folder api/internal/tests/auth 
dengan doc api -> mengunakan swagger 
 - di dalam folder api/internal/docs sesuai nama module semisal auth 
// dengan bahasa indo dan inggris 

Buatkan login frontend 
 - login mengunakan table users kolom email dan password
 - dengan validasi email dan password harus diisi
 - dengan jwt token (ambil dari api mengunakan http)
 - di dalam folder 
  - client/lib/models
  - client/lib/screens/auth
  - clinet/lib/services
  - clinet/lib/providers
dengan unit test dan integration test 
 - di dalam folder client/test/auth 
// dengan bahasa indo dan inggris 