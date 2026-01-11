Filmistik – Sosyal Film Keşif ve Öneri Uygulaması

Filmistik, kullanıcıların film keşfedebildiği, kendi film önerilerini ekleyebildiği ve toplulukla etkileşime girebildiği modern bir mobil uygulamadır.
Uygulama Flutter ile geliştirilmiş, Firebase altyapısı ve OMDb API entegrasyonu ile desteklenmiştir.

Kullanıcılar film ekleyebilir, favorilerine kaydedebilir, admin onayından geçen içerikleri keşfedebilir ve gelişmiş filtreleme özellikleriyle aradıkları filmleri hızlıca bulabilir.

Projenin Amacı

Bu projenin amacı, kullanıcıların film keşfetme sürecini daha etkileşimli ve kişiselleştirilebilir hale getirmektir.
Kullanıcı katkıları, admin kontrol mekanizması ve modern arayüz tasarımı sayesinde Filmistik, sosyal bir film platformu deneyimi sunar.

Temel Özellikler

Kullanıcı tarafı:

Kullanıcılar Firebase Authentication ile kayıt olabilir ve giriş yapabilir.
Profil sayfasında kendi bilgilerini, eklediği filmleri ve favorilerini görebilir.
Favori filmleri kaydedip kaldırabilir.
Şifre sıfırlama işlemini e-posta üzerinden gerçekleştirebilir.

Film keşfi:

Filmler modern grid (ızgara) yapısında listelenir.
Tür bazlı filtreleme yapılabilir.
Film adı, oyuncu adı ve anahtar kelimelere göre arama yapılabilir.
Türkçe karakter uyumlu arama sistemi bulunur.

Film ekleme:

OMDb API üzerinden film afişi, başrol oyuncuları ve IMDb puanı çekilir.
Kullanıcı anahtar kelimeler ekleyebilir.
Eklenen filmler admin onayından geçmeden yayınlanmaz.

Admin paneli:

Onay bekleyen filmler görüntülenir.
Filmler düzenlenebilir, onaylanabilir veya silinebilir.
Yayındaki filmler yönetilebilir.

Arayüz:

Scroll’a duyarlı arama alanı bulunur.
Kategoriler kaydırıldıkça küçülür ve kaybolur.
Dark Mode uyumlu modern tasarım kullanılmıştır.

Kullanılan Teknolojiler

Frontend: Flutter (Dart)
Backend: Firebase Realtime Database
Kimlik Doğrulama: Firebase Authentication
API: OMDb API
Arayüz: Material Design
Veri Akışı: StreamBuilder
Navigasyon: Navigator
HTTP İstekleri: http paketi

Proje Yapısı

Proje modüler bir yapıda geliştirilmiştir.

lib klasörü altında:

models: Veri modelleri
services: Firebase servisleri
screens: Uygulama ekranları
main.dart: Ana giriş noktası

Bu yapı sayesinde proje kolayca genişletilebilir ve sürdürülebilir hale getirilmiştir.

Veri Akışı

Kullanıcı giriş yapar.
Film ekler.
Film "pending" olarak Firebase’e kaydedilir.
Admin panelinden onaylanır.
Onaylanan film ana sayfada yayınlanır.
Kullanıcılar arama, filtreleme ve favori işlemleri yapar.

API Entegrasyonu

Filmistik, film verilerini OMDb API üzerinden çeker.

Kullanılan endpoint:

https://www.omdbapi.com/?t=FilmAdi&apikey=API_KEY

Çekilen veriler:

Poster
Actors
IMDb Rating
Genre

Arama Sistemi

Türkçe karakter uyumluluğu için özel normalizasyon uygulanır:

İ ve I harfleri Türkçe kurallara göre dönüştürülür.
Arama küçük harfe çevrilir ve trim edilir.

Bu sayede:

"Şeytanın Avukatı"
"Seytanin Avukati"

aynı sonucu verir.

Kitap Listesi / Ek Dosyalar

Bu repoya aşağıdaki gibi ek dosyalar ekleyebilirsin:

kitap_listesi.pdf
kitap_listesi.txt
kaynaklar.docx

Dosyayı proje kök dizinine yükleyip README’ye şu şekilde referans verebilirsin:

Kitap Listesi:
kitap_listesi.pdf dosyası proje dizininde bulunmaktadır.

Geliştirici

Ramazan Koçdemir
Yönetim Bilişim Sistemleri
Bilgisayar Mühendisliği Yandal
Kurucu: Rakosoft

E-posta: ramazankocdemirr@gmail.com

LinkedIn: https://www.linkedin.com/company/rakosoft

Instagram: https://www.instagram.com/rakosoft
