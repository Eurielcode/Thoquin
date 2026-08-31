# Thoquin — Route du Futur

Système d'orientation académique pour étudiants : de la Licence vers le Master (USA/UK).
Pilote : étudiants en Licence Computer Science à Lancaster University (Ghana campus).

> Ce README est un **document vivant** : il est mis à jour à chaque changement significatif, pour que n'importe quelle session (Claude ou une autre IA) puisse reprendre le projet avec le contexte à jour, sans avoir à tout relire depuis le début.

---

## 1. Objectif du projet

Un étudiant en Licence sait rarement, de façon concrète et actualisée, vers quels Masters il peut réellement se diriger, à quelles bourses il est éligible, et ce qu'il lui manque pour atteindre ses ambitions. Route du Futur construit un profil académique vivant (notes réelles, ambitions, compétences) qui se met à jour dans le temps et génère automatiquement une liste de Masters et de bourses compatibles.

Le cahier des charges complet est dans [`docs/cahier-des-charges.md`](docs/cahier-des-charges.md).

## 2. Périmètre V1

| Critère | Choix |
|---|---|
| Niveau | Licence → Master |
| Zone Master | USA + UK |
| Filière pilote | Computer Science |
| Groupe pilote | Étudiants Lancaster University (Ghana), Licence CS |

**Note sur le périmètre des Masters** : élargi volontairement au-delà de "Computer Science" au sens strict, pour couvrir tout le cluster tech — IA/Machine Learning, Data Science, Software Engineering, Cybersécurité, Robotique.

## 3. État d'avancement (dernière mise à jour : voir historique Git)

### ⚠️ Blocage connu — important à lire avant de relancer une extraction automatique

**Cet environnement d'exécution bloque l'accès direct (WebFetch) à tous les domaines `.ac.uk` et `.edu` testés**, sans exception (Oxford, Imperial, Edinburgh, UCL côté UK ; MIT, Stanford, CMU, Berkeley côté US — 8 domaines différents, échec systématique `EGRESS_BLOCKED`). Ce n'est pas un problème de site indisponible, c'est une restriction réseau de l'environnement lui-même. **Ne pas réessayer WebFetch sur ces domaines depuis un environnement avec la même config réseau — ça échouera pareil.**

Options pour débloquer l'extraction des critères d'admission :
1. **Fournir le contenu texte des pages directement** (copier-coller depuis un navigateur, ou capture d'écran) — l'IA peut alors extraire les critères depuis ce texte/image sans passer par WebFetch.
2. **Relancer depuis un environnement/outil sans ce blocage réseau** (poste local, autre session Claude Code avec une config réseau différente).
3. Utiliser une source tierce déjà agrégée (moins fiable, à valider manuellement).

Vu le volume (~90 pages), la meilleure approche pratique est probablement de **prioriser un petit sous-ensemble** (5-10 Masters les plus pertinents pour le profil de l'étudiant pilote) pour copier-coller/screenshot manuellement, plutôt que d'essayer de traiter les 90 d'un coup.

### Décidé
- **Architecture de matching** : le matching Master/bourse est du code déterministe (comparaison de seuils), **pas** un appel LLM — gratuit, fiable, pas d'hallucination possible.
- **Extraction des critères d'admission** : LLM utilisé uniquement pour transformer le texte brut des pages d'admission en JSON structuré, une fois par programme (pas par étudiant) — coût négligeable (~1-5$ pour ~250 programmes sur 20 universités). *Bloqué en pratique par le point réseau ci-dessus, pas par le coût.*
- **Choix LLM pour l'extraction** : pas figé. Options envisagées : Gemini (free tier généreux, bon pour démarrer à 0€), Claude (payant mais fiable sur documents ambigus/tableaux), open source auto-hébergé (0€, plus de travail d'infra).
- **URLs des pages d'admission** : à collecter une fois et stocker en dur (elles changent rarement) — pas de crawler intelligent nécessaire. Première passe faite, voir ci-dessous.
- **Saisie des notes** : pas de texte libre. L'étudiant sélectionne ses modules dans un catalogue préchargé et rentre ses notes **composante par composante** (coursework, exam...) au fur et à mesure qu'elles tombent dans l'année — pas seulement la note finale, pour permettre de se projeter un an à l'avance (les candidatures Master se préparent bien avant les résultats finaux).
- **Anglais** : pour Lancaster Ghana (cursus en anglais), un interrupteur "exempté du test d'anglais" remplace le score IELTS par défaut ; le champ IELTS reste disponible si l'étudiant n'est pas exempté.
- **Direction visuelle** : esthétique "chunky" façon Duolingo (boutons avec effet 3D pressable, couleurs franches et saturées, typographie ronde Baloo 2 + Nunito Sans) — choisie après recherche sur le phénomène "AI slop design" pour éviter le look générique par défaut (Inter, violet Tailwind, cartes pastel arrondies).

### Construit (prototype front-end, pas encore connecté à un vrai backend)
Un prototype HTML/JS interactif est dans [`prototype/route-du-futur.html`](prototype/route-du-futur.html), avec 3 écrans :
1. **Mon profil / Interactive Transcript** — reproduit la structure du vrai relevé Lancaster (onglets Part I / Part II), saisie des notes par composante avec recalcul en direct de la moyenne pondérée provisoire et un indicateur "% de l'année saisie".
2. **Masters** — 3 colonnes Accessible / À consolider / Ambitieux, écart précis affiché par critère (pas un vague "non éligible"), panneau de détail au clic avec comparaison visuelle par critère.
3. **Bourses** — même logique d'écart précis, critère manquant nommé explicitement.

Données de référence collectées :
- [`docs/universites-cibles.md`](docs/universites-cibles.md) — les 20 universités cibles (10 UK + 10 US, classement QS 2026 CS). **Statut brouillon**, rangs 8-10 de chaque liste à confirmer sur la source officielle.
- [`docs/masters-urls.md`](docs/masters-urls.md) — ~90 programmes de Master (IA, Data Science, Software Engineering, Cybersécurité, Robotique) avec leurs URLs, pour les 20 universités. **Extraction des critères bloquée pour l'instant (voir avertissement ci-dessus)**. Trois constats structurels importants à retenir :
  - **MIT, Princeton et Caltech n'ont pas de master terminal classique ouvert aux candidats externes** (le "MS"/"SM" y est une étape du doctorat) — à traiter comme cas particuliers dans le modèle de données.
  - **Stanford ne propose qu'un seul diplôme (MSCS) avec des spécialisations nommées**, pas plusieurs masters séparés.
  - Quelques programmes mentionnés par les universités elles-mêmes n'ont pas pu être retrouvés avec une URL fiable (signalé explicitement dans le fichier plutôt que d'inventer un lien).

### Pas encore fait
- **Vérification finale de la liste des 20 universités** : confirmer les rangs 8-10 UK/US sur topuniversités.com (bloqué depuis cet environnement, à faire manuellement ou depuis un autre outil).
- **Extraction des critères d'admission réels** : bloquée par la restriction réseau `.ac.uk`/`.edu` de cet environnement (voir encadré ci-dessus) — aucun critère (GPA, IELTS, deadline, coût) n'a pu être extrait automatiquement pour l'instant.
- **1ère année (Part I)** : catalogue de modules encore placeholder, en attente des vraies données Lancaster.
- **Pas de vrai backend** : ni base de données, ni authentification, ni API — tout tourne côté client dans un seul fichier HTML.
- **Pondération Coursework/Exam** : déduite approximativement des vraies notes de l'étudiant pilote, pas la formule officielle exacte de Lancaster.
- **Adoption étudiante** : réflexion produit évoquée mais pas creusée (comment convaincre d'autres étudiants Lancaster d'utiliser l'outil).

## 4. Prochaines étapes proposées

1. ~~Identifier les 10 meilleures universités UK + 10 meilleures universités US en Computer Science~~ — fait, voir [`docs/universites-cibles.md`](docs/universites-cibles.md) (à valider sur les rangs 8-10).
2. ~~Repérer les URLs des pages d'admission Master de chacune des 20 universités~~ — fait (première passe), voir [`docs/masters-urls.md`](docs/masters-urls.md) (à valider, URLs non fetchées directement).
3. **Extraire les vrais critères d'admission** — bloqué par le réseau depuis cet environnement. Prochaine tentative : demander à l'utilisateur de copier-coller le contenu de 5-10 pages prioritaires (ou d'envoyer des captures d'écran), plutôt que de compter sur WebFetch.
4. Choisir la méthode d'extraction définitive (Gemini free tier vs Claude vs open source) selon le budget et le volume réel.
5. Obtenir les vraies données de 1ère année (Part I) de l'étudiant pilote pour compléter le relevé interactif.
6. Concevoir le vrai modèle de données (étudiant, université, Master, critère d'admission, bourse) et l'architecture backend.
7. Recruter un ou plusieurs étudiants Lancaster CS testeurs pour valider le concept avec de vraies données.

## 5. Structure du dépôt

```
├── README.md                       # ce fichier — état d'avancement à jour
├── docs/
│   ├── cahier-des-charges.md       # spécification initiale du projet
│   ├── universites-cibles.md       # les 20 universités cibles (UK/US, Computer Science)
│   └── masters-urls.md             # URLs des Masters (cluster tech) par université — brouillon
└── prototype/
    └── route-du-futur.html         # prototype interactif (ouvrir dans un navigateur)
```

## 6. Note pour toute IA qui reprend ce projet

Lis ce README en entier avant de proposer quoi que ce soit — il résume toutes les décisions déjà prises et pourquoi, pour éviter de refaire les mêmes débats (choix du LLM, format des notes, design visuel...). Le prototype HTML est autonome (pas de dépendances à installer) : ouvre-le directement dans un navigateur pour voir l'état actuel de l'interface. Après toute modification significative (nouvelle fonctionnalité, décision d'architecture, changement de direction), mets à jour la section 3 de ce README avant de terminer la session.

**Point d'attention technique confirmé (ne pas re-tester)** : dans cet environnement d'exécution, WebFetch est bloqué (EGRESS_BLOCKED) pour tous les domaines `.ac.uk` et `.edu` testés à ce jour — testé sur 8 universités différentes (UK et US), échec systématique. Si tu es une nouvelle session dans le même environnement, ne perds pas de temps à retester WebFetch sur ces domaines : demande plutôt à l'utilisateur de coller le contenu texte ou une capture d'écran des pages, ou vérifie si l'environnement a changé.
