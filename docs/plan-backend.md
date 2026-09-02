# Plan backend — Route du Futur

Objectif : passer du prototype front-end seul (un fichier HTML avec tout codé en dur) à une vraie application multi-utilisateurs, sans sur-ingénierie pour un pilote qui démarre avec un seul étudiant réel.

## 1. Choix de stack : Supabase

**Recommandation : Supabase** (Postgres + Auth + API auto-générée, hébergé, free tier généreux) plutôt qu'un backend fait maison (Node/Express + base de données séparée).

Pourquoi :
- **Auth incluse** (email/mot de passe ou lien magique) — pas besoin de coder un système de comptes.
- **API REST auto-générée** à partir des tables — pas besoin d'écrire un serveur qui expose des routes, juste définir les tables.
- **Row Level Security (RLS)** native — chaque étudiant ne voit/modifie que ses propres notes, géré au niveau base de données plutôt qu'en code applicatif (donc pas de bug possible où un étudiant verrait les notes d'un autre).
- **Free tier** largement suffisant pour un pilote (500 Mo de base de données, largement au-dessus du besoin ; bien plus d'utilisateurs actifs que ce dont on aura besoin avant longtemps).
- **Postgres** = base relationnelle classique, adaptée à des données structurées comme les nôtres (modules, composantes, critères Masters).

Alternative écartée : Firebase (NoSQL, moins naturel pour des données aussi relationnelles que "module → composantes → notes").

## 2. Modèle de données (tables Postgres)

```
students
  id (uuid, = auth.users.id)
  name, institution, current_year
  english_exempt (bool), ielts_score (numeric)

student_modules
  id, student_id (fk students), part_year (int), year_label (text)
  code, name, credits, indicative (bool)

student_components
  id, module_id (fk student_modules)
  name, weight (numeric), mark (numeric, nullable)

universities
  id, name, country

masters_programs
  id, university_id (fk universities), program_name, tags (text[])
  req_avg (numeric, nullable), req_label (text)
  req_ielts (numeric, nullable), english_note (text)
  cost (text), deadline (text), other_pieces (text[])
  excluded (bool), exclusion_note (text)
  source_confidence (enum: 'official_page' | 'websearch_official' | 'websearch_thirdparty')

scholarships
  id, name, coverage, applies, deadline (text)
  eligibility_note (text)
  source_confidence (même enum)
```

Le champ **`source_confidence`** généralise la distinction qu'on a déjà faite à la main dans les fichiers markdown (page officielle lue directement vs. WebSearch officiel vs. estimation tierce) — ça devient un vrai champ filtrable/affichable plutôt qu'une mention dans un texte libre.

`req_avg`/`req_ielts` restent **nullable** — même principe que dans le prototype actuel : jamais de valeur inventée, `null` = "non trouvé" et déclenche la catégorie "Données incomplètes" côté affichage.

## 3. Sécurité (Row Level Security)

- `students`, `student_modules`, `student_components` : policy "un utilisateur ne peut lire/écrire que les lignes où `student_id = auth.uid()`".
- `universities`, `masters_programs`, `scholarships` : lecture publique (tout le monde peut consulter), écriture réservée à un rôle `admin` (toi, au départ).

## 4. Migration des données existantes

Étape ponctuelle : écrire un script (Python ou Node) qui lit les tableaux `MASTERS`/`SCHOLARSHIPS` actuels du prototype (ou directement `criteres-admission.md`/`criteres-bourses.md`) et génère les `INSERT` SQL correspondants pour peupler `universities`/`masters_programs`/`scholarships`. Fait une seule fois à la mise en place, puis les mises à jour futures se font directement dans les tables (via l'interface Supabase, pas besoin d'interface admin custom pour un pilote à un seul admin).

## 5. Ce qui change dans le prototype (front-end)

Le HTML/CSS/JS existant n'a pas besoin d'être réécrit dans un framework — il peut continuer à tourner tel quel, avec 3 changements :

1. **Charger les données au lieu de les coder en dur** : remplacer les tableaux `MASTERS`/`SCHOLARSHIPS` par un appel à l'API Supabase au chargement de la page (`supabase.from('masters_programs').select()`).
2. **Ajouter connexion/inscription** : un écran de login simple (email + lien magique, pour éviter la gestion de mots de passe) via le SDK JS de Supabase.
3. **Sauvegarder les notes en base** : dans `renderModuleCard()`, l'écouteur `input` qui met à jour `comp.mark` doit aussi écrire la valeur dans `student_components` via `supabase.from('student_components').update(...)`, au lieu de ne vivre qu'en mémoire JS.

Le moteur de matching (`classify()`, `gapText()`...) reste **côté client, en JavaScript** — c'est du calcul déterministe et bon marché, pas besoin de le déplacer côté serveur.

## 6. Étapes concrètes, dans l'ordre

1. Créer un projet Supabase (gratuit).
2. Créer les tables ci-dessus (fichier SQL versionné dans le dépôt, ex. `db/schema.sql`).
3. Configurer les policies RLS.
4. Écrire et lancer le script de migration des données actuelles (`criteres-admission.md`/`criteres-bourses.md` → tables).
5. Activer l'authentification par email (lien magique) dans Supabase.
6. Modifier `prototype/route-du-futur.html` : écran de connexion, chargement des données via l'API au lieu des tableaux en dur, sauvegarde des notes en base.
7. Héberger le front-end statiquement (GitHub Pages ou Vercel, gratuit) — Supabase héberge déjà la base et l'API, rien à gérer côté serveur.
8. Tester avec ton propre compte, puis avec 1-2 autres étudiants Lancaster CS pour valider que chacun voit bien uniquement ses propres notes.
9. (Plus tard) Mettre à jour les données Masters/Bourses directement dans les tables Supabase chaque année, sans toucher au code du front-end.

## 7. Ce que ce plan ne couvre pas (volontairement, pour rester réaliste pour un pilote)

- Pas d'interface d'administration custom dans un premier temps — l'éditeur de tables intégré à Supabase suffit pour un seul admin.
- Pas de framework front-end (React, etc.) — pas nécessaire tant que l'UI reste de la taille actuelle.
- Pas de pipeline d'extraction automatisée des critères d'admission — ça reste un processus manuel (Claude for Chrome) exécuté une à deux fois par an, pas un système à construire.
