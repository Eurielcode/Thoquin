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

**Le board Masters tourne maintenant sur les vraies données extraites : 91 programmes** (sur les 96 de `criteres-admission.md` — 5 exclus, voir plus bas). Décision de design pour gérer les trous côté US sans jamais inventer de seuil : le board a **4 catégories** au lieu de 3 — Accessible / À consolider / Ambitieux / **Données incomplètes** (grise, nouvelle). Un programme tombe dans "Données incomplètes" dès que sa moyenne requise (`reqAvg`) n'a pas été trouvée sur sa page officielle ; l'IELTS manquant seul ne bloque pas un programme (`reqIelts === null` est traité comme non pénalisant, mais affiché comme "non trouvé"). Les deadlines et coûts réels étant du texte hétérogène (pas des dates ISO propres), le compte à rebours coloré a été abandonné pour les Masters et remplacé par du texte brut ; ce mécanisme reste utilisé tel quel pour la section Bourses (dates ISO propres). Le lien "fiche source" de chaque programme pointe vers `docs/criteres-admission.md` sur GitHub.

**2e passe d'extraction US terminée** (à la demande de l'utilisateur, pour économiser sa limite d'usage Claude for Chrome, la recherche a été découpée en 3 lots — A : MIT/Stanford/CMU, B : Berkeley/Georgia Tech/Princeton, C : Cornell/UIUC/Michigan — ciblés sur les pages Admissions Requirements/Tuition/Deadlines des départements, plutôt que la seule page de présentation du programme). Résultat : beaucoup de seuils GPA/IELTS/coûts/deadlines auparavant "non trouvé" sont maintenant renseignés (CMU MSAII/MCDS/MSE, Berkeley MIDS/MICS, Georgia Tech MSCS/MSA, Cornell MEng, UIUC MCS...). Le champ qui résiste le plus, même avec une recherche ciblée : **le coût annuel côté US**, souvent publié en \$/semestre sur des pages Bursar génériques non ventilées par programme (CMU, Georgia Tech, Cornell, une partie de Michigan), ou carrément derrière une authentification bloquante (page tarifs de Princeton, protégée CAS). Ces montants bruts (par semestre) sont affichés tels quels dans le prototype plutôt que d'être extrapolés en coût annuel.

**5 programmes exclus du board** car confirmés non ouverts à un candidat externe : MIT MEng EECS et MIT EECS Graduate Programs en général (confirmé "no terminal master's degree" pour candidature externe directe — c'est un parcours doctoral), Caltech (le MS y est décerné en cours de PhD), UC Berkeley 5th Year MIDS (réservé aux étudiants Berkeley en 4e année). Un 6e programme, **MIT MS Computational Science and Engineering, reste affiché** mais avec un avertissement : ses admissions externes sont actuellement en pause (n'accepte que des étudiants MIT en double diplôme).

**La section Bourses tourne maintenant sur 6 vraies bourses** (Chevening, Fulbright Ghana, Commonwealth Shared Scholarship, Rhodes Scholarship Afrique de l'Ouest, GREAT Scholarships, Mastercard Foundation Scholars Program) au lieu des données d'exemple d'origine. Trouvaille importante au passage : la "Lancaster Global Achievers Award" des données d'exemple était fictive — la vraie bourse Lancaster (Alumni Loyalty Scholarship, 10% de réduction) existe bien mais ne s'applique qu'à un Master **à Lancaster elle-même**, pas aux 20 universités cibles du projet, donc écartée du board. Ces données viennent de WebSearch (pas de lecture directe de page, voir section 6) et sont donc marquées comme moins vérifiées que celles des Masters — un lien "fiche source" pointe vers `docs/criteres-bourses.md`. Les deadlines non-ISO (bourse décentralisée, cycle fermé, date non publiée) s'affichent en texte brut comme pour les Masters, plutôt que de forcer une fausse date.

Données de référence collectées :
- [`docs/universites-cibles.md`](docs/universites-cibles.md) — 20 universités cibles (10 UK + 10 US, QS 2026 CS). Rangs 8-10 de chaque liste à confirmer.
- [`docs/masters-urls.md`](docs/masters-urls.md) — ~96 programmes avec leurs URLs.
- [`docs/criteres-admission.md`](docs/criteres-admission.md) — extraction complète (96/96 programmes) + **2e passe terminée sur les 37 programmes US** : classification/GPA, anglais requis, deadline, coût, autres pièces, extraits des vraies pages via Claude for Chrome.
- [`docs/criteres-bourses.md`](docs/criteres-bourses.md) — **NOUVEAU**, 6 bourses réelles avec éligibilité/couverture/deadline, trouvées via WebSearch (méthode différente de celle des Masters, voir section 6).

**Constats importants issus de l'extraction :**
- **Beaucoup de champs "non trouvé" côté US, mais nettement moins qu'après la 1ère passe.** Les universités britanniques affichent en général tout sur une seule page. Les universités américaines répartissaient les critères chiffrés sur des sous-pages séparées ("Admissions Requirements", "Tuition and Fees", "How to Apply") non couvertes par les URLs de départ ; la 2e passe ciblée sur ces sous-pages a comblé une bonne partie des trous (voir ci-dessus).
- **Ce qui résiste encore malgré la recherche ciblée** : le coût annuel pour CMU (plusieurs programmes), Georgia Tech, Princeton (page tarifs protégée par authentification CAS), Cornell, et University of Michigan CSE (erreur 403 sur la page College of Engineering) ; Georgia Tech MS Cybersecurity (sur campus) reste presque entièrement vide.
- **5 programmes confirmés sans master terminal ouvert aux candidats externes**, désormais exclus du board (voir "Construit" ci-dessus) : MIT EECS (SM/MEng, y compris MEng), Caltech, UC Berkeley 5th Year MIDS.
- Plusieurs deadlines UK sont déjà passées ou les candidatures sont fermées au moment de l'extraction (fin août 2026) — à revérifier à la réouverture des cycles 2027.
- Erreurs techniques ponctuelles : page Stanford "Master's Admissions" inaccessible (403 persistant même en 2e tentative).

### Pas encore fait
- **Combler les derniers trous de coût US** (CMU, Georgia Tech, Princeton, Cornell, Michigan CSE) — nécessiterait probablement un contact direct avec les départements plutôt qu'une recherche web, vu les pages protégées/non ventilées rencontrées.
- **Vérification finale de la liste des 20 universités** : confirmer les rangs 8-10 UK/US sur topuniversités.com.
- **Backend branché, pas encore testé en conditions réelles** : le prototype (`prototype/route-du-futur.html`) charge maintenant `MASTERS`/`SCHOLARSHIPS` depuis Supabase au lieu de tableaux en dur, a un écran de connexion par lien magique (email), et lit/sauvegarde le profil + les notes en base (`students`/`student_modules`/`student_components`). Projet Supabase créé par l'utilisateur (`iihevbisbccnurjxgxbn`), schéma et clé anon branchés. **Reste à faire** : confirmer que `db/schema.sql`/`db/seed.sql` ont bien été exécutés dans l'éditeur SQL (pas vérifiable depuis cette session, réseau sortant bloqué), et **tester via un vrai hébergement** — le lien Artifact claude.ai ne fonctionne plus pour ça, son bac à sable bloque les appels réseau externes comme Supabase. Voir [`docs/plan-backend.md`](docs/plan-backend.md).
- **Pondération Coursework/Exam** du prototype : approximative, pas la formule officielle exacte de Lancaster.
- **Adoption étudiante** : réflexion produit évoquée mais pas creusée.
- **Vérification des bourses via Claude for Chrome** : les 6 bourses de `criteres-bourses.md` viennent de WebSearch, pas d'une lecture directe des pages officielles — à re-vérifier avant une vraie candidature (deadlines et listes d'universités éligibles surtout).

## 4. Prochaines étapes proposées

1. ~~Identifier les 20 universités cibles~~ — fait, voir [`universites-cibles.md`](docs/universites-cibles.md).
2. ~~Repérer les URLs des Masters~~ — fait, voir [`masters-urls.md`](docs/masters-urls.md).
3. ~~Extraire les critères d'admission réels~~ — fait pour 96/96 programmes + 2e passe ciblée sur les 37 programmes US, voir [`criteres-admission.md`](docs/criteres-admission.md).
4. ~~Brancher les vraies données sur le prototype~~ — fait : le board Masters tourne sur 91 vraies fiches (5 exclues, non ouvertes aux externes), avec la catégorie "Données incomplètes" pour les seuils encore non trouvés.
5. **Combler les derniers trous de coût US** (CMU, Georgia Tech, Princeton, Cornell, Michigan CSE) — probablement par contact direct plutôt que recherche web, voir "Pas encore fait" ci-dessus.
6. ~~Collecter les vraies bourses~~ — fait pour 6 bourses (Chevening, Fulbright Ghana, Commonwealth, Rhodes, GREAT, Mastercard Foundation), voir [`criteres-bourses.md`](docs/criteres-bourses.md) ; à vérifier via Claude for Chrome avant usage réel.
7. ~~Implémenter le backend~~ — fait côté code : projet Supabase créé, prototype branché (connexion, données, notes). **Reste à tester réellement** via un hébergement statique (GitHub Pages/Vercel) — voir [`plan-backend.md`](docs/plan-backend.md).
8. Recruter un ou plusieurs étudiants Lancaster CS testeurs.

## 5. Structure du dépôt

```
├── README.md                       # ce fichier — état d'avancement à jour
├── docs/
│   ├── cahier-des-charges.md       # spécification initiale du projet
│   ├── universites-cibles.md       # les 20 universités cibles (UK/US, Computer Science)
│   ├── masters-urls.md             # URLs des Masters (cluster tech) par université
│   ├── criteres-admission.md       # critères d'admission réels extraits (96/96 programmes)
│   ├── criteres-bourses.md         # 6 bourses réelles (éligibilité/couverture/deadline)
│   └── plan-backend.md             # plan détaillé pour passer du prototype à une vraie appli (Supabase)
├── db/
│   ├── schema.sql                  # tables Postgres + policies RLS (à exécuter dans Supabase)
│   ├── seed.sql                    # données réelles prêtes à insérer (généré, ne pas éditer à la main)
│   └── generate-seed.js            # régénère seed.sql depuis le prototype (node db/generate-seed.js)
└── prototype/
    └── route-du-futur.html         # prototype interactif (ouvrir dans un navigateur)
```

## 6. Note pour toute IA qui reprend ce projet

Lis ce README en entier avant de proposer quoi que ce soit. Le prototype HTML est autonome (pas de dépendances) : ouvre-le directement dans un navigateur. Après toute modification significative, mets à jour la section 3 de ce README avant de terminer la session.

**Points d'attention technique confirmés (ne pas re-tester) :**
- WebFetch est bloqué (EGRESS_BLOCKED) dans cet environnement — **pas seulement sur `.ac.uk`/`.edu`** comme supposé au départ : confirmé aussi sur des domaines `.org`/`.gov` (chevening.org, fulbrightonline.org, mastercardfdn.org, cscuk.fcdo.gov.uk). Le blocage semble large, pas limité aux domaines universitaires.
- **WebSearch fonctionne, lui, et peut suffire pour des données moins critiques** : contrairement à WebFetch, WebSearch (recherche + résumé, pas de lecture directe de page) n'est pas bloqué. Utilisé avec succès pour : (1) des coûts US manquants côté Masters — mais attention, ces résultats viennent souvent d'agrégateurs tiers non officiels (Yocket, Collegedunia...), à marquer explicitement "estimation non officielle" ; (2) les 6 bourses de `criteres-bourses.md` — là les résumés citent des pages officielles (chevening.org, cscuk.fcdo.gov.uk...) donc plus fiables, mais toujours pas une lecture mot-à-mot. Bien vérifier la provenance (officielle vs agrégateur) avant de décider du niveau de confiance à afficher.
- **Pour une extraction fiable/complète, Claude for Chrome reste la meilleure solution** (extension navigateur, tourne sur le réseau de l'utilisateur, sans ce blocage) : demander à l'utilisateur de visiter les pages et coller le résultat en texte ici. C'est comme ça que `criteres-admission.md` a été rempli à l'origine.
- Attention en cas de reprise après une longue pause utilisateur ("j'ai atteint ma limite d'usage") : vérifier si le message concerne bien cette session-ci ou une autre session Claude en parallèle (Claude for Chrome notamment) — ça a déjà causé une confusion.
