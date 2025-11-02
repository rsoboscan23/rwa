# BAZA PODATAKA - RWA Multimedijska Aplikacija

## Pregled

Ovo je baza podataka za web aplikaciju koja upravlja multimedijskim sadržajem.

### Glavne značajke:

✅ Upravljanje multimedijskim kolekcijama (filmovi, serije, glazba, podcasti, knjige, igre)
✅ Integracija sa TMDB servisom
✅ Vlastiti sadržaj
✅ 4 razine korisničkih uloga
✅ Straničenje podataka na serveru
✅ Ocjenjivanje i recenzije
✅ Omiljeni sadržaj

---

## Struktura baze

### 1. ROLES (Uloge)

Definira korisničke uloge sa hijerarhijom:

| Kolona | Tip | Opis |
|--------|-----|------|
| id | INT | Jedinstveni ID |
| name | VARCHAR(50) | Naziv uloge (guest, user, moderator, admin) |
| level | INT | Razina ovlasti (1-4) |
| description | VARCHAR(255) | Opis uloge |

**Unaprijed definirane uloge:**
- **GOST** (level 1) - Samo čitanje
- **KORISNIK** (level 2) - Može dodavati sadržaj, ocjenjivati
- **MODERATOR** (level 3) - Može odobravati sadržaj
- **ADMIN** (level 4) - Potpuna kontrola

---

### 2. USERS (Korisnici)

Pohranjuje korisničke račune:

| Kolona | Tip | Opis |
|--------|-----|------|
| id | INT | Jedinstveni ID |
| username | VARCHAR(50) | Korisničko ime (jedinstveno) |
| email | VARCHAR(100) | Email adresa (jedinstvena) |
| password_hash | VARCHAR(255) | Hashirana lozinka |
| first_name | VARCHAR(50) | Ime |
| last_name | VARCHAR(50) | Prezime |
| role_id | INT | Veza na ROLES tablicu |
| is_active | BOOLEAN | Je li račun aktivan |
| email_verified | BOOLEAN | Je li email potvrđen |
| created_at | TIMESTAMP | Datum registracije |
| last_login | TIMESTAMP | Zadnja prijava |

---

### 3. MEDIA_ITEMS (Multimedijski sadržaj)

Glavna tablica sa svim sadržajem:

| Kolona | Tip | Opis |
|--------|-----|------|
| id | INT | Jedinstveni ID |
| title | VARCHAR(255) | Naslov |
| media_type | ENUM | Tip: movie, tv_series, music, podcast, book, game |
| description | TEXT | Opis sadržaja |
| release_date | DATE | Datum izlaska |
| poster_url | VARCHAR(500) | URL postera |
| tmdb_id | INT | ID iz TMDB servisa |
| imdb_id | VARCHAR(20) | IMDB ID |
| source | ENUM | Izvor: 'tmdb' ili 'internal' |
| popularity | DECIMAL | Popularnost |
| vote_average | DECIMAL | Prosječna ocjena |
| is_approved | BOOLEAN | Je li sadržaj odobren |
| added_by_user_id | INT | Tko je dodao sadržaj |
| approved_by_user_id | INT | Tko je odobrio sadržaj |

---

### 4. ACTORS (Glumci)

| Kolona | Tip | Opis |
|--------|-----|------|
| id | INT | Jedinstveni ID |
| name | VARCHAR(100) | Ime glumca |
| birth_date | DATE | Datum rođenja |
| biography | TEXT | Biografija |
| profile_url | VARCHAR(500) | URL slike profila |
| tmdb_id | INT | TMDB ID |

---

### 5. GENRES (Žanrovi)

| Kolona | Tip | Opis |
|--------|-----|------|
| id | INT | Jedinstveni ID |
| name | VARCHAR(50) | Naziv žanra (jedinstveno) |
| tmdb_id | INT | TMDB ID žanra |

**Unaprijed dodani žanrovi:** Action, Adventure, Animation, Comedy, Crime, Documentary, Drama, Family, Fantasy, History, Horror, Music, Mystery, Romance, Science Fiction, Thriller, War, Western (ukupno 19)

---

### 6. MEDIA_ACTORS (Veza mediji-glumci)

Spaja media_items sa actors (many-to-many):

| Kolona | Tip | Opis |
|--------|-----|------|
| id | INT | Jedinstveni ID |
| media_id | INT | ID medija |
| actor_id | INT | ID glumca |
| character_name | VARCHAR(100) | Ime lika |
| cast_order | INT | Redoslijed u glumačkoj ekipi |

---

### 7. MEDIA_GENRES (Veza mediji-žanrovi)

Spaja media_items sa genres (many-to-many):

| Kolona | Tip | Opis |
|--------|-----|------|
| id | INT | Jedinstveni ID |
| media_id | INT | ID medija |
| genre_id | INT | ID žanra |

---

### 8. REVIEWS (Recenzije)

Korisničke recenzije za sadržaj:

| Kolona | Tip | Opis |
|--------|-----|------|
| id | INT | Jedinstveni ID |
| media_id | INT | ID medija |
| user_id | INT | ID korisnika |
| title | VARCHAR(255) | Naslov recenzije |
| content | TEXT | Sadržaj recenzije |
| is_approved | BOOLEAN | Je li odobrena |
| approved_by_user_id | INT | Tko je odobrio |

---

### 9. RATINGS (Ocjene)

Korisničke ocjene (0.0 - 10.0):

| Kolona | Tip | Opis |
|--------|-----|------|
| id | INT | Jedinstveni ID |
| media_id | INT | ID medija |
| user_id | INT | ID korisnika |
| rating | DECIMAL(2,1) | Ocjena (0.0 - 10.0) |

**Ograničenje:** Jedan korisnik može dati samo jednu ocjenu po sadržaju.

---

### 10. USER_FAVORITES (Omiljeni sadržaj)

Omiljeni mediji korisnika:

| Kolona | Tip | Opis |
|--------|-----|------|
| id | INT | Jedinstveni ID |
| user_id | INT | ID korisnika |
| media_id | INT | ID medija |

---

## Veze između tablica

### One-to-Many (Jedan-na-više):
- **roles → users** (1:∞) - Jedna uloga, mnogo korisnika
- **users → media_items** (1:∞) - Korisnik dodaje mnogo sadržaja
- **users → reviews** (1:∞) - Korisnik piše mnogo recenzija
- **media_items → reviews** (1:∞) - Sadržaj ima mnogo recenzija

### Many-to-Many (Mnogo-na-mnogo):
- **media_items ↔ actors** (preko media_actors)
- **media_items ↔ genres** (preko media_genres)
- **users ↔ media_items** (preko user_favorites)

---

## Straničenje (Pagination)

Uključene su stored procedure za straničenje:

### sp_get_paginated_media
Dohvaća medije sa straničenjem:
- Parametri: stranica, veličina stranice, tip medija, pretraga, sortiranje
- Vraća: rezultate + ukupan broj zapisa

### sp_get_paginated_users
Dohvaća korisnike sa straničenjem (samo za admina):
- Parametri: stranica, veličina stranice, ID uloge, pretraga
- Vraća: rezultate + ukupan broj zapisa

**Primjer korištenja:**
```sql
-- Dohvati prvu stranicu sa 20 filmova
CALL sp_get_paginated_media(1, 20, 'movie', NULL, 'popularity_desc');

-- Dohvati drugu stranicu korisnika
CALL sp_get_paginated_users(2, 50, NULL, NULL);
```

---

## Pogledi (Views)

### v_users_with_roles
Prikazuje korisnike sa podacima o ulogama.

### v_media_with_stats
Prikazuje medije sa statistikama:
- Prosječna ocjena
- Broj ocjena
- Broj recenzija
- Broj favorita
- Popis žanrova

---

## Sigurnost

### Foreign Key akcije:
- **ON DELETE CASCADE** - Brisanje roditelja briše i djecu (za recenzije, ocjene, favorite)
- **ON DELETE SET NULL** - Brisanje roditelja postavlja NULL (za added_by, approved_by)
- **ON DELETE RESTRICT** - Sprječava brisanje ako postoje djeca (za roles)

### Jedinstvena ograničenja:
- Username i email moraju biti jedinstveni
- Jedan korisnik = jedna ocjena po sadržaju
- Jedan korisnik = jedan favorit po sadržaju

### Indeksi:
- Svi Foreign Key-evi imaju indekse
- Česta pretraživanja imaju indekse (title, media_type, popularity, itd.)

---

## Kako koristiti u aplikaciji?

1. **Autentifikacija:**
   - Provjeri username/password u USERS tablici
   - Dohvati role_id i provjeri razinu ovlasti

2. **Kontrola pristupa:**
   - GOST (level 1): Samo čitanje odobrenog sadržaja
   - KORISNIK (level 2): + Dodavanje, ocjenjivanje, recenziranje
   - MODERATOR (level 3): + Odobravanje sadržaja i recenzija
   - ADMIN (level 4): + Upravljanje korisnicima

3. **Prikaz sadržaja:**
   - Koristi `v_media_with_stats` view za listu
   - Implementiraj straničenje sa stored procedurama
   - Za goste: Prikaži samo `is_approved = TRUE`

4. **TMDB integracija:**
   - Dohvati podatke iz TMDB API-ja
   - Spremi u MEDIA_ITEMS sa `source = 'tmdb'` i popuni `tmdb_id`
   - Za vlastiti sadržaj: `source = 'internal'`

---

## Dodatne napomene

- **Charset:** utf8mb4 (podržava emoji i međunarodne znakove)
- **Engine:** InnoDB (podržava transakcije i FK)
- **Zadana lozinka admina:** Treba promijeniti prije produkcije!

---

## Potrebna pomoć?

Pogledaj **UPUTE.md** za korake kako importati ovu shemu u MySQL Workbench.

