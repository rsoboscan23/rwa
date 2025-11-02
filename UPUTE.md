# UPUTE ZA KORIŠTENJE - ER Dijagram u MySQL Workbench

## Što trebaš napraviti?

### Korak 1: Preuzmi datoteku

1. Idi na GitHub stranicu ovog repozitorija
2. Klikni na datoteku **`database_schema.sql`**
3. Klikni na gumb **"Raw"** (gore desno)
4. **Desni klik** na stranicu → **"Save Page As..."** ili **"Spremi stranicu kao..."**
5. Spremi datoteku na računalo (npr. u Downloads)

### Korak 2: Otvori MySQL Workbench

1. Pokreni **MySQL Workbench** program
2. Klikni na **File** → **New Model** (ili Ctrl+N)

### Korak 3: Importaj SQL datoteku

1. U novom modelu, klikni **File** → **Import** → **Reverse Engineer MySQL Create Script...**
2. Pronađi i odaberi preuzetu **`database_schema.sql`** datoteku
3. Klikni **Execute**
4. Klikni **Next** → **Next** → **Finish**

### Korak 4: Vidi ER dijagram

1. U panelu sa lijeve strane, pod "Physical Schemas", vidjet ćeš tvoju bazu podataka
2. **Dupli klik** na "Add Diagram" ili klikni **Model** → **Create Diagram from Catalog Objects**
3. **ER dijagram će se automatski prikazati!** 🎉

### Korak 5: Uredi dijagram (opcionalno)

- Možeš pomicati tablice povlačenjem mišem
- Za automatsko raspoređivanje: **Arrange** → **Auto-Layout**
- Možeš zumirati sa Ctrl + kotačić miša

---

## Alternativni način (ako imaš MySQL server)

### Korak 1: Kreiraj bazu podataka

Otvori MySQL Workbench i poveži se na server, zatim:

```sql
CREATE DATABASE rwa_multimedia;
USE rwa_multimedia;
```

### Korak 2: Importaj SQL

1. Klikni **Server** → **Data Import**
2. Odaberi **"Import from Self-Contained File"**
3. Pronađi **`database_schema.sql`** datoteku
4. Odaberi **"Default Target Schema"** → **rwa_multimedia**
5. Klikni **Start Import**

### Korak 3: Reverse Engineer

1. Klikni **Database** → **Reverse Engineer...**
2. Poveži se na server
3. Odaberi bazu **rwa_multimedia**
4. Klikni **Next** → **Next** → **Execute** → **Next** → **Finish**
5. ER dijagram je gotov!

---

## Što je u bazi podataka?

Baza ima **10 tablica**:

1. **roles** - Uloge korisnika (gost, korisnik, moderator, admin)
2. **users** - Korisnički računi
3. **media_items** - Multimedijski sadržaj (filmovi, serije, glazba...)
4. **actors** - Glumci
5. **genres** - Žanrovi
6. **media_actors** - Veza između medija i glumaca
7. **media_genres** - Veza između medija i žanrova
8. **reviews** - Recenzije korisnika
9. **ratings** - Ocjene korisnika
10. **user_favorites** - Omiljeni sadržaj korisnika

### Hijerarhija uloga:

```
ADMIN (razina 4) - Sve ovlasti
   ↓
MODERATOR (razina 3) - Može odobravati sadržaj
   ↓
KORISNIK (razina 2) - Može ocjenjivati i recenzirati
   ↓
GOST (razina 1) - Može samo gledati
```

---

## Problem?

### MySQL Workbench ne otvara SQL datoteku?

- Provjeri je li datoteka spremljena s pravim ekstenzijom `.sql` (ne `.sql.txt`)
- Otvori datoteku u Notepad++ ili drugom editoru i provjeri ima li greške

### Ne vidiš dijagram?

- Klikni **Model** → **Create Diagram from Catalog Objects**
- Odaberi sve tablice i klikni **Place Selected Objects**

### Trebаš pomoć?

- Pogledaj datoteke **DATABASE_README.md** i **ER_DIAGRAM_GUIDE.md** za detaljnije upute (na engleskom)

---

## Spremno! 🚀

Sada možeš:
- Vidjeti sve tablice i veze između njih
- Eksportirati dijagram kao sliku (File → Export → Export as PNG/PDF/SVG)
- Modificirati shemu prema potrebi
- Koristiti ovu shemu za razvoj web aplikacije

