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

### Comment on a débloqué l'extraction (contournement du blocage réseau)
Cet environnement d'exécution bloque WebFetch sur tous les domaines `.ac.uk`/`.edu` (confirmé, ne pas re-tester). La solution qui a marché : l'utilisateur a utilisé **Claude for Chrome** (extension navigateur, session séparée tournant sur son propre réseau) pour visiter les ~96 pages une par une et en extraire les critères, puis a collé le résultat ici pour intégration au dépôt. Cette méthode fonctionne bien mais demande un aller-retour manuel utilisateur ↔ session Chrome ↔ ce dépôt.

### Décidé
- **Architecture de matching** : le matching Master/bourse est du code déterministe (comparaison de seuils), **pas** un appel LLM — gratuit, fiable, pas d'hallucination possible.
- **Extraction des critères d'admission** : LLM utilisé pour transformer le texte brut des pages d'admission en JSON structuré. **Fait pour 96/96 programmes** (voir ci-dessous), via Claude for Chrome plutôt que WebFetch direct (bloqué dans cet environnement).
- **Choix LLM pour l'extraction future** (mises à jour annuelles, nouvelles universités) : pas figé. Options envisagées : Gemini (free tier généreux), Claude (fiable sur documents ambigus), open source auto-hébergé.
- **URLs des pages d'admission** : collectées une fois, stockées en dur — voir [`masters-urls.md`](docs/masters-urls.md).
- **Saisie des notes** : pas de texte libre. L'étudiant sélectionne ses modules dans un catalogue préchargé et rentre ses notes **composante par composante** (coursework, exam...) au fur et à mesure qu'elles tombent dans l'année.
- **Anglais** : pour Lancaster Ghana (cursus en anglais), un interrupteur "exempté du test d'anglais" remplace le score IELTS par défaut.
- **Direction visuelle** : esthétique "chunky" façon Duolingo (boutons 3D pressable, couleurs franches, typographie ronde Baloo 2 + Nunito Sans).

### Construit
Un prototype HTML/JS interactif est dans [`prototype/route-du-futur.html`](prototype/route-du-futur.html), avec 3 écrans (Mon profil/Interactive Transcript, Masters, Bourses).

**Le board Masters tourne maintenant sur les vraies données extraites : 93 programmes** (sur les 96 de `criteres-admission.md` — Caltech et la piste MEng EECS réservée aux internes du MIT ont été exclus, voir plus bas). Décision de design pour gérer les trous côté US sans jamais inventer de seuil : le board a **4 catégories** au lieu de 3 — Accessible / À consolider / Ambitieux / **Données incomplètes** (grise, nouvelle). Un programme tombe dans "Données incomplètes" dès que sa moyenne requise (`reqAvg`) n'a pas été trouvée sur sa page officielle ; l'IELTS manquant seul ne bloque pas un programme (`reqIelts === null` est traité comme non pénalisant, mais affiché comme "non trouvé"). Les deadlines et coûts réels étant du texte hétérogène (pas des dates ISO propres), le compte à rebours coloré a été abandonné pour les Masters et remplacé par du texte brut ; ce mécanisme reste utilisé tel quel pour la section Bourses (dates ISO propres). Le lien "fiche source" de chaque programme pointe vers `docs/criteres-admission.md` sur GitHub.

Seule la section Bourses tourne encore sur des données d'exemple (Fulbright, Chevening...).

Données de référence collectées :
- [`docs/universites-cibles.md`](docs/universites-cibles.md) — 20 universités cibles (10 UK + 10 US, QS 2026 CS). Rangs 8-10 de chaque liste à confirmer.
- [`docs/masters-urls.md`](docs/masters-urls.md) — ~96 programmes avec leurs URLs.
- [`docs/criteres-admission.md`](docs/criteres-admission.md) — **NOUVEAU, extraction complète (96/96 programmes)** : classification/GPA, anglais requis, deadline, coût annuel, autres pièces, extraits des vraies pages via Claude for Chrome.

**Constats importants issus de l'extraction :**
- **Beaucoup de champs "non trouvé", surtout côté US.** Les universités britanniques affichent en général tout sur une seule page. Les universités américaines (MIT, Stanford, CMU, Princeton, Cornell, Caltech, UIUC, Michigan, une partie de Georgia Tech) renvoient les critères chiffrés vers des sous-pages séparées ("Admissions Requirements", "Tuition and Fees", "How to Apply") non couvertes par les URLs de départ — **une passe complémentaire ciblée sur ces sous-pages est nécessaire** pour compléter les GPA/TOEFL/deadlines/coûts manquants côté US.
- **MIT et Caltech confirmés sans master terminal ouvert aux candidats externes** (MEng EECS MIT réservé aux étudiants internes ; Caltech MS uniquement en cours de PhD).
- Plusieurs deadlines UK sont déjà passées ou les candidatures sont fermées au moment de l'extraction (fin août 2026) — à revérifier à la réouverture des cycles 2027.
- Erreurs techniques ponctuelles : page Stanford "Master's Admissions" inaccessible (403), 2 pages MIT redirigées vers une page générique sans détail.

### Pas encore fait
- **Compléter les "non trouvé" côté US** via une passe ciblée sur les sous-pages Admissions/Tuition/How-to-Apply — c'est le plus gros trou restant : la majorité des programmes US tombent dans "Données incomplètes" faute de seuil chiffré trouvé.
- **Vérification finale de la liste des 20 universités** : confirmer les rangs 8-10 UK/US sur topuniversités.com.
- **1ère année (Part I)** de l'étudiant pilote : catalogue de modules encore placeholder.
- **Pas de vrai backend** : ni base de données, ni authentification, ni API — tout tourne côté client dans un seul fichier HTML.
- **Pondération Coursework/Exam** du prototype : approximative, pas la formule officielle exacte de Lancaster.
- **Adoption étudiante** : réflexion produit évoquée mais pas creusée.
- **Bourses réelles** : toujours des données d'exemple (Fulbright, Chevening...), pas encore de vraie collecte de critères de bourses.

## 4. Prochaines étapes proposées

1. ~~Identifier les 20 universités cibles~~ — fait, voir [`universites-cibles.md`](docs/universites-cibles.md).
2. ~~Repérer les URLs des Masters~~ — fait, voir [`masters-urls.md`](docs/masters-urls.md).
3. ~~Extraire les critères d'admission réels~~ — fait pour 96/96 programmes (beaucoup de champs "non trouvé" côté US à compléter), voir [`criteres-admission.md`](docs/criteres-admission.md).
4. ~~Brancher les vraies données sur le prototype~~ — fait : le board Masters tourne sur les 93 vraies fiches, avec la catégorie "Données incomplètes" pour les seuils non trouvés.
5. **Compléter les critères manquants côté US** (sous-pages Admissions/Tuition/How-to-Apply non couvertes en premier passage) — fera reculer la catégorie "Données incomplètes".
6. Obtenir les vraies données de 1ère année (Part I) de l'étudiant pilote.
7. Collecter les vraies bourses (critères, montants, deadlines) — même méthode que pour les Masters.
8. Concevoir le vrai modèle de données et l'architecture backend (au-delà du prototype front-end seul).
9. Recruter un ou plusieurs étudiants Lancaster CS testeurs.

## 5. Structure du dépôt

```
├── README.md                       # ce fichier — état d'avancement à jour
├── docs/
│   ├── cahier-des-charges.md       # spécification initiale du projet
│   ├── universites-cibles.md       # les 20 universités cibles (UK/US, Computer Science)
│   ├── masters-urls.md             # URLs des Masters (cluster tech) par université
│   └── criteres-admission.md       # critères d'admission réels extraits (96/96 programmes)
└── prototype/
    └── route-du-futur.html         # prototype interactif (ouvrir dans un navigateur)
```

## 6. Note pour toute IA qui reprend ce projet

Lis ce README en entier avant de proposer quoi que ce soit. Le prototype HTML est autonome (pas de dépendances) : ouvre-le directement dans un navigateur. Après toute modification significative, mets à jour la section 3 de ce README avant de terminer la session.

**Points d'attention technique confirmés (ne pas re-tester) :**
- WebFetch est bloqué (EGRESS_BLOCKED) pour tous les domaines `.ac.uk`/`.edu` testés dans cet environnement — testé sur 8+ universités, échec systématique.
- **Solution qui fonctionne** : demander à l'utilisateur d'utiliser Claude for Chrome (extension navigateur, tourne sur son propre réseau, sans ce blocage) pour visiter les pages et coller le résultat en texte ici. C'est comme ça que `criteres-admission.md` a été rempli.
- Attention en cas de reprise après une longue pause utilisateur ("j'ai atteint ma limite d'usage") : vérifier si le message concerne bien cette session-ci ou une autre session Claude en parallèle (Claude for Chrome notamment) — ça a déjà causé une confusion.
