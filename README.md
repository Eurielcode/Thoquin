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

## 3. État d'avancement (dernière mise à jour : voir historique Git)

### Décidé
- **Architecture de matching** : le matching Master/bourse est du code déterministe (comparaison de seuils), **pas** un appel LLM — gratuit, fiable, pas d'hallucination possible.
- **Extraction des critères d'admission** : LLM utilisé uniquement pour transformer le texte brut des pages d'admission en JSON structuré, une fois par programme (pas par étudiant) — coût négligeable (~1-5$ pour ~250 programmes sur 20 universités).
- **Choix LLM pour l'extraction** : pas figé. Options envisagées : Gemini (free tier généreux, bon pour démarrer à 0€), Claude (payant mais fiable sur documents ambigus/tableaux), open source auto-hébergé (0€, plus de travail d'infra).
- **URLs des pages d'admission** : à collecter une fois et stocker en dur (elles changent rarement) — pas de crawler intelligent nécessaire.
- **Saisie des notes** : pas de texte libre. L'étudiant sélectionne ses modules dans un catalogue préchargé et rentre ses notes **composante par composante** (coursework, exam...) au fur et à mesure qu'elles tombent dans l'année — pas seulement la note finale, pour permettre de se projeter un an à l'avance (les candidatures Master se préparent bien avant les résultats finaux).
- **Anglais** : pour Lancaster Ghana (cursus en anglais), un interrupteur "exempté du test d'anglais" remplace le score IELTS par défaut ; le champ IELTS reste disponible si l'étudiant n'est pas exempté.
- **Direction visuelle** : esthétique "chunky" façon Duolingo (boutons avec effet 3D pressable, couleurs franches et saturées, typographie ronde Baloo 2 + Nunito Sans) — choisie après recherche sur le phénomène "AI slop design" pour éviter le look générique par défaut (Inter, violet Tailwind, cartes pastel arrondies).

### Construit (prototype front-end, pas encore connecté à un vrai backend)
Un prototype HTML/JS interactif est dans [`prototype/route-du-futur.html`](prototype/route-du-futur.html), avec 3 écrans :
1. **Mon profil / Interactive Transcript** — reproduit la structure du vrai relevé Lancaster (onglets Part I / Part II), saisie des notes par composante avec recalcul en direct de la moyenne pondérée provisoire et un indicateur "% de l'année saisie".
2. **Masters** — 3 colonnes Accessible / À consolider / Ambitieux, écart précis affiché par critère (pas un vague "non éligible"), panneau de détail au clic avec comparaison visuelle par critère.
3. **Bourses** — même logique d'écart précis, critère manquant nommé explicitement.

### Pas encore fait
- **Données réelles non vérifiées** : les critères des Masters et les bourses affichés sont illustratifs, pas vérifiés sur les sites officiels des universités.
- **1ère année (Part I)** : catalogue de modules encore placeholder, en attente des vraies données Lancaster.
- **Pas de vrai backend** : ni base de données, ni authentification, ni API — tout tourne côté client dans un seul fichier HTML.
- **Pondération Coursework/Exam** : déduite approximativement des vraies notes de l'étudiant pilote, pas la formule officielle exacte de Lancaster.
- **Adoption étudiante** : réflexion produit évoquée mais pas creusée (comment convaincre d'autres étudiants Lancaster d'utiliser l'outil).
- **Collecte des vraies données** : les ~250 programmes de Master sur les 20 meilleures universités US/UK en Computer Science ne sont pas encore identifiés ni extraits.

## 4. Prochaines étapes proposées

1. Identifier les 10 meilleures universités UK + 10 meilleures universités US en Computer Science, et lister leurs URLs de pages d'admission Master (une fois, à stocker en dur).
2. Choisir la méthode d'extraction définitive (Gemini free tier vs Claude vs open source) selon le budget et le volume réel.
3. Obtenir les vraies données de 1ère année (Part I) de l'étudiant pilote pour compléter le relevé interactif.
4. Concevoir le vrai modèle de données (étudiant, université, Master, critère d'admission, bourse) et l'architecture backend.
5. Recruter un ou plusieurs étudiants Lancaster CS testeurs pour valider le concept avec de vraies données.

## 5. Structure du dépôt

```
├── README.md                      # ce fichier — état d'avancement à jour
├── docs/
│   └── cahier-des-charges.md      # spécification initiale du projet
└── prototype/
    └── route-du-futur.html        # prototype interactif (ouvrir dans un navigateur)
```

## 6. Note pour toute IA qui reprend ce projet

Lis ce README en entier avant de proposer quoi que ce soit — il résume toutes les décisions déjà prises et pourquoi, pour éviter de refaire les mêmes débats (choix du LLM, format des notes, design visuel...). Le prototype HTML est autonome (pas de dépendances à installer) : ouvre-le directement dans un navigateur pour voir l'état actuel de l'interface. Après toute modification significative (nouvelle fonctionnalité, décision d'architecture, changement de direction), mets à jour la section 3 de ce README avant de terminer la session.
