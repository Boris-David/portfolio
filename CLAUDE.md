# Portfolio — workspace

Portfolio personnel décliné en **plusieurs produits qui partagent un seul
contenu** : une web app et une app iOS native, reliées par des deep links.

Objectif : être lu par des recruteurs et des équipes techniques comme la preuve
d'un niveau senior — pas comme une page « à propos ». Chaque artefact d'ici est
une **pièce à conviction** : code, architecture, tests et pipelines sont publics
et doivent tenir sous inspection.

## Périmètre — NON NÉGOCIABLE

> **Ce workspace est scopé `portfolio`, et rien d'autre.**

Rien d'ici ne dépend d'un autre projet de la machine, et rien d'ici n'écrit chez
eux. Détail et cas limites : `.claude/rules/scope-isolation.md`.

## Où vit une instruction — le critère

Le mécanisme est natif : une règle de `.claude/rules/` **sans** `paths:` se
charge à **chaque session**, exactement comme ce fichier ; **avec** `paths:`,
elle ne se charge **que** si je lis un fichier qui matche le glob.

Le contexte est une ressource finie : une instruction chargée en permanence
alors qu'elle ne sert qu'à une stack **dégrade l'adhérence à toutes les autres**.
D'où la règle, qui se décide sur **l'étendue du sujet**, jamais sur la taille du
fichier :

| L'instruction régit… | Où elle vit | `paths:` |
|---|---|---|
| tout le workspace, toujours (périmètre, posture, workflow git) | `portfolio/CLAUDE.md` ou `portfolio/.claude/rules/` | **non** |
| tout un dépôt, dès qu'on y touche | `<dépôt>/CLAUDE.md` | — |
| une **sous-surface** d'un dépôt (tests, i18n, design system, CI) | `<dépôt>/.claude/rules/<sujet>.md` | **oui** |
| une procédure qu'on **invoque** (release, audit, revue) | une skill, pas une règle | — |

**Le spécifique reste dans le spécifique.** Une instruction qui ne concerne que
l'iOS vit dans le dépôt iOS et nulle part ailleurs — jamais remontée ici « au
cas où ». Un glob se résout depuis le répertoire qui porte le `.claude/`.

> Ce n'est pas déclaratif : le hook `InstructionsLoaded` journalise ce qui s'est
> **réellement** chargé, et sert à vérifier qu'une règle scopée ne fuit pas dans
> les sessions qui ne la concernent pas.

## État

Phase de cadrage. Ce fichier se complète à mesure que chaque décision devient du
code.
