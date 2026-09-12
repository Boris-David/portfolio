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

## La seule exception

Les ressources qui sont par nature **au niveau du compte**, et qu'aucun projet ne
peut posséder en propre :

- le compte GitHub `Boris-David` ;
- le compte Apple Developer et son Team ID `R55L6Z8K6R`.

Tout ce qui se décline **par projet** au-dessus de ces comptes (dépôts, branches,
identifiants d'app, clés d'API, profils, certificats, projets cloud) est **dédié
au portfolio**.

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
