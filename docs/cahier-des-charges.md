# Cahier des charges — "Route du Futur"
### Système d'orientation académique pour étudiants (V1 : de la Licence vers le Master, USA/UK)

---

## 1. Contexte et objectif

Un étudiant en Licence sait rarement, de façon concrète et actualisée :
- vers quels Masters il peut réellement se diriger, compte tenu de son profil actuel ;
- à quelles bourses il est éligible ;
- ce qu'il lui manque encore (notes, compétences, expériences) pour atteindre ses ambitions.

**Objectif du projet :** créer un système où l'étudiant construit un profil académique vivant (filière, notes réelles, ambitions, compétences) qui se met à jour au fil du temps, et qui génère automatiquement une liste de Masters et de bourses compatibles avec ce profil.

**Nom de travail :** *Route du Futur*

---

## 2. Périmètre de la version 1 (V1)

| Critère | Choix V1 |
|---|---|
| Niveau ciblé | **De la Licence vers le Master** |
| Zone géographique visée (Masters) | **États-Unis et Royaume-Uni** |
| Filière pilote | **Computer Science** |
| Groupe pilote | Étudiants **actuellement inscrits à Lancaster University**, en Licence Computer Science |

### Point de départ de l'étudiant pilote
- Il est **actuellement à Lancaster University**, en Licence Computer Science.
- Son profil réel (ses vraies notes, semestre par semestre, dans ce cursus précis) sert de **base concrète** pour le matching — pas une estimation, ses données réelles.

### Objectif final de l'étudiant
- Trouver vers quel **Master** se diriger ensuite — à Lancaster ou ailleurs (USA/UK) — avec une liste réaliste d'options et de bourses correspondantes.

**Hors périmètre V1 :**
- Autres pays que USA/UK pour le Master
- Autres filières que Computer Science
- Application mobile (interface web pour commencer)
- Candidature automatique aux universités (le système recommande, il ne postule pas à la place de l'étudiant)

---

## 3. Parcours utilisateur type

1. L'étudiant crée son profil : Lancaster University, Computer Science, année en cours.
2. Il renseigne ses **notes réelles**, matière par matière, semestre par semestre, au fur et à mesure qu'il les reçoit.
3. Il indique ses ambitions pour le Master — même vagues ("je veux faire un Master en IA", "un truc technique aux US, pas encore sûr lequel").
4. Il ajoute ses compétences : langages, projets, stages, certifications, niveau d'anglais (IELTS/TOEFL si déjà passé).
5. Le système lui affiche une liste de Masters classés, par exemple :
   - **Accessible maintenant** (il remplit déjà les critères)
   - **À consolider** (proche, mais il manque un élément précis, ex. : GPA ou score de langue)
   - **Ambitieux** (objectif possible avec un effort clair)
6. Pour chaque option, le système indique **l'écart précis** avec les critères réels (ex. : "GPA actuel 3.1, minimum requis pour ce Master 3.4").
7. Le système croise aussi son profil avec les **bourses disponibles** et leurs deadlines.
8. Il revient mettre à jour son profil au fil de l'année → les recommandations se recalculent automatiquement.

---

## 4. Fonctionnalités principales

### 4.1 Profil étudiant évolutif
- Université actuelle (Lancaster), filière (Computer Science), année d'étude
- Notes réelles par matière et semestre, avec conversion GPA (les échelles de notation diffèrent selon les systèmes — à définir précisément avec le système de notation de Lancaster)
- Ambitions : champ libre + tags de domaines (IA, Data Science, Cybersécurité, etc.) + pays visés
- Compétences : langages, projets, stages, certifications
- Niveau d'anglais : score IELTS/TOEFL si disponible, sinon auto-déclaré
- Historique du profil dans le temps (pour suivre la progression)

### 4.2 Moteur de matching
- Compare le profil réel de l'étudiant aux critères d'admission réels des Masters (GPA minimum, niveau d'anglais requis, prérequis, lettres de recommandation, etc.)
- Classe les résultats : Accessible / À consolider / Ambitieux
- Indique l'écart précis pour chaque option non encore accessible

### 4.3 Moteur de bourses
- Croise le profil avec une base de bourses (critères, montants, deadlines, pays d'origine accepté)
- Alerte sur les deadlines à venir

### 4.4 Base de données référentiel
- Masters en Computer Science (USA/UK) : critères d'admission, coût, deadlines, spécialisations
- Bourses associées (internes aux universités ou indépendantes, ex. : Fulbright, Chevening)

> **À définir ensemble :** la source de ces données (saisie manuelle pour démarrer, scraping des sites officiels, ou API si elles existent). Pour le pilote, on peut commencer par une saisie manuelle des critères réels de quelques Masters cibles, ce qui suffit largement pour valider le concept.

### 4.5 Suivi dans le temps
- Recommandations recalculées à chaque mise à jour du profil
- Optionnel V1.1 : rappels sur les deadlines de candidature ou de bourses

---

## 5. Données à collecter (profil étudiant)

| Catégorie | Détail |
|---|---|
| Identité académique | Lancaster University, Computer Science, année en cours |
| Résultats | Notes réelles par matière/semestre, GPA calculé/converti |
| Ambitions | Texte libre + tags de domaines + pays visés |
| Compétences | Langages/outils, projets, stages, certifications |
| Langue | Score IELTS/TOEFL si disponible, sinon niveau auto-déclaré |
| Objectifs financiers | Besoin de bourse ou non, budget disponible |

---

## 6. Critères de succès du pilote

1. Un étudiant de Lancaster CS peut créer un profil complet en moins de 15 minutes.
2. Le système produit une liste de Masters cohérente avec les vrais critères d'admission (vérifiés sur les sites officiels des universités cibles).
3. Au moins une bourse pertinente est correctement identifiée pour un profil type.
4. Un étudiant testeur confirme que les recommandations lui semblent utiles et compréhensibles.

---

## 7. Prochaines étapes proposées

1. Choisir 3 à 5 **Masters cibles** (USA/UK, Computer Science) pour constituer le premier jeu de données test, avec leurs critères réels.
2. Lister les **bourses** correspondantes.
3. Définir le **modèle de données** (étudiant, université, filière, Master, critère d'admission, bourse).
4. Faire un **schéma du parcours utilisateur / architecture du système**.
5. Construire un **prototype d'interface** (profil + résultats de matching) pour un premier test avec de vrais étudiants de Lancaster.

---

*Document de travail — à faire évoluer au fil de nos échanges.*

---

## Addendum — évolutions décidées après la rédaction initiale

Ce cahier des charges a été enrichi au fil des discussions. Les décisions suivantes complètent ou précisent le document ci-dessus (détail complet dans le [README](../README.md)) :

- **Échelle géographique réelle** : le pilote couvre en fait les 10 meilleures universités UK + 10 meilleures universités US en Computer Science (tous leurs Masters liés à CS), pas seulement 3-5 Masters — soit environ 250 programmes à terme.
- **Groupe pilote précisé** : Lancaster University, campus du Ghana (cursus intégralement en anglais) — ce qui a changé la gestion du niveau d'anglais (voir ci-dessous).
- **Anglais** : remplacé par un interrupteur "exempté du test d'anglais" plutôt qu'un score IELTS obligatoire, car les étudiants de ce campus étudient déjà en anglais. Le score IELTS reste disponible pour les étudiants non exemptés.
- **Notes** : saisie non pas comme une seule note finale par matière, mais **composante par composante** (coursework, exam...) au fur et à mesure qu'elles tombent dans l'année, avec un système de moyenne provisoire — pour que l'étudiant puisse se projeter avant la fin de l'année scolaire (les candidatures Master se préparent ~1 an à l'avance).
