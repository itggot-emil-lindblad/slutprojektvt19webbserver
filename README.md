# slutprojektvt19webbserver

# Projektplan

## 1. Projektbeskrivning
Kommer göra en CMS för hantering och redigering av 
webbsidan till Prästkragens Förskola. Syftet är att man enkelt ska kunna redigera personal informationen samt
skriva nyhetsinlägg. Du kommer att logga in och mötas av en dashboard där man sedan kan välja delsida för nyheter eller personal. På dessa sidor ser man alla nyheter eller personal profiler. Dessa kan redigeras eller tas bort helt. Man kan även skapa nya inlägg och profiler. När du har gjort redigeringar så kommer applikationen rendera statiska HTML filer som sedan
kan laddas upp till webbhotell. (Inte implementerat ännu)
## 2. Vyer (sidor)
1. Login
2. Dashboard
3. Nyhetsinlägg
* Skapa nytt inlägg
* Redigera inlägg
* Ta bort inlägg
4. Personal
* Lägga till personalprofil
* Redigera personalprofil
* Ta bort personalproil
5. Redigera inloggning
6. Unauthorized sida vid fel inloggning
## 3. Funktionalitet (med sekvensdiagram)
Se misc mappen
## 4. Arkitektur (Beskriv filer och mappar)
```
.
├── app.rb Controler fil, sköter alla inkommade routes
├── config.ru Config-fil för Rack
├── database.rb Model fil sköter all integration med databasen  
├── db Mapp för databasen
│   └── data.db Databasfil
├── Gemfile Fil för bundler, vilka gems som ska användas
├── Gemfile.lock Fil för bundler, vilka gems som ska användas
├── misc Er och sekvensdiagram
│   ├── erdiagram(1).xml Er-diagram i xml format
│   ├── erdiagram.png Er-diagram
│   ├── loginsequence.png Skevens diagram
│   └── newpostsequence.png Sekvens diagram
├── public Allt som är tillängligt för klienten
│   ├── css Mapp för css fil
│   │   └── style.css Css fil
│   └── img Mapp för bilder
│       ├── 1097e3cff6eaa36bd037.jpg Bild
│       ├── 1feca29957105f6701d4.jpg Bild
│       ├── 263cfb8137064a751d9d.jpg Bild
│       ├── 296b6329a41d4ee0532e.png Bild
│       ├── 3a3c8b5f914546f4d5bd.jpg Bild
│       ├── 51b386866d1af53ff02c.png Bild
│       ├── 5fe17ab9f67e7064161b.jpg Bild
│       ├── 781bd59ff5c4833eeb1d.jpg Bild
│       ├── 7aec069eb247f01bc16a.jpg Bild
│       └── 812100c8ed6009a67cff.png Bild
├── rakefile Config fil för Rake
├── README.md Readme fil
├── render.rb Fil som innehåller funktioner för rendering til html
├── run Script för att starta applikationen
└── views Mapp för View
    ├── editemployee.slim Mall fil
    ├── editpost.slim Mall fil
    ├── editprofile.slim Mall fil
    ├── employees.slim Mall fil
    ├── empty.slim Mall fil
    ├── index.slim Mall fil
    ├── layout.slim Mall fil
    ├── loginlayout.slim Mall fil
    ├── login.slim Mall fil
    ├── newemployee.slim Mall fil
    ├── newpost.slim Mall fil
    └── news.slim Mall fil
```
## 5. (Databas med ER-diagram)
Se misc mappen
