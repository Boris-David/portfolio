# Isolation du périmètre `portfolio` — NON NÉGOCIABLE

> Règle racine : elle s'applique à **toute** session ouverte dans
> `/Users/PC205/Work/learning/ai-projects/portfolio` et ses sous-répertoires.

## La règle

**Le portfolio est scopé `portfolio`. Aucun autre projet de la machine n'est une
source, un modèle, ni une dépendance — et le portfolio n'écrit jamais chez eux.**

C'est valable **dans les deux sens**, et en particulier vis-à-vis de **KCalories**
(`../kcalories`), qui est un projet distinct de l'utilisateur.

## Ce que ça interdit, concrètement

| Geste | Statut |
|---|---|
| Lire `../kcalories/**` (ou tout autre projet) pour décider ici | **interdit** — ce n'est pas une source de vérité pour le portfolio |
| Copier ses `.claude/` (rules, hooks, agents, skills), ses workflows CI, ses scripts | **interdit** — le setup du portfolio s'écrit de zéro |
| Justifier un choix par « c'est comme ça dans l'autre projet » | **interdit** — un choix se justifie sur son mérite technique **ici** |
| Écrire, modifier, supprimer quoi que ce soit hors de ce workspace | **interdit** |
| Réutiliser un artefact **par projet** d'un autre projet : dépôt de certificats `match`, projet GCP, bucket, clé d'API, secret, branche, domaine | **interdit** — le portfolio a les siens, dédiés |
| Pousser sur un dépôt GitHub qui n'est pas un dépôt du portfolio | **interdit** |

## Les exceptions — deux, nommées, et pas une de plus

### 1. Les ressources de compte

Celles qui sont par nature **au niveau du compte**, et qu'aucun projet ne peut
posséder en propre :

- le compte GitHub `Boris-David` ;
- le compte Apple Developer et son Team ID `R55L6Z8K6R`.

Tout ce qui se décline **par projet** au-dessus de ces comptes (dépôts, branches,
identifiants d'app, clés d'API, profils, certificats, projets cloud) est **dédié
au portfolio**.

### 2. Lire les dépôts de travail de l'auteur — pour en tirer des FAITS

*Autorisée explicitement par l'auteur le 2026-09-17.*

Les dépôts de travail personnels sous `~/Work` **hors** `ai-projects/`
(`socle-v1`, `socle-v2`…) peuvent être **lus** — historique git, code, commits —
dans un seul but : **extraire des faits vérifiables sur le travail de l'auteur**
pour alimenter le contenu du portfolio. Le portfolio parle de ce qu'il a fait ;
son propre code est la source la plus fiable pour le dire juste.

Cette exception est **étroite**, et ce qu'elle ne couvre pas compte autant :

| | |
|---|---|
| Lire pour établir un fait à publier | **autorisé** |
| **Écrire** quoi que ce soit là-bas | **interdit, sans exception** |
| Copier leur setup, leurs règles, leur outillage | **interdit** — l'exception porte sur le *contenu*, jamais sur la *méthode* |
| Publier du code, un nom de client ou un détail interne sans accord | **interdit** — ce qui est citable se décide avec l'auteur, pas par défaut |

### 3. Lire un projet voisin que le portfolio CITE

Un projet voisin sous `ai-projects/` devient **lisible** — et lisible seulement —
dès lors que le portfolio **le cite dans son contenu** : on ne peut pas présenter
un projet honnêtement sans pouvoir en établir les faits (dates de démarrage,
périmètre, volume). La liste vit dans la garde, variable `READABLE_SIBLINGS`.

Tout le reste de `ai-projects/` demeure **entièrement fermé, lecture comprise**.
Et pour un projet cité, la porte ne s'ouvre que dans un sens : **aucune écriture,
et aucune reprise de son setup** — l'exception porte sur ce qu'il *est*, jamais
sur la façon dont il *est fait*.

### Ce qui tient ces règles

`.claude/hooks/guard-repo-scope.sh`, branché sur `Bash` **et** sur les outils
d'écriture de fichiers (`Write`, `Edit`, `NotebookEdit`) — ne couvrir que Bash
laissait un trou béant, un agent écrivant des fichiers sans passer par un shell.
Falsifié par `.claude/hooks/__tests__/scope_test.sh` (18 cas, témoins compris).

## Le pourquoi

Deux projets, deux cycles de vie. Un setup partagé crée un couplage invisible :
une règle qui évolue d'un côté contraint ou casse l'autre, et le périmètre de
chaque dépôt devient indéchiffrable — pour un humain comme pour un agent. Ici
l'enjeu est doublé : ces dépôts sont **montrés à des recruteurs**, donc chacun
doit se lire seul, sans contexte externe.

## Ce que KCalories est ici, et seulement ça

**Un projet cité dans le contenu du portfolio** — une entrée de la liste des
réalisations, avec sa description, ses captures et ses liens. Son *contenu*
éditorial a sa place ici ; son *setup* n'en a aucune.
