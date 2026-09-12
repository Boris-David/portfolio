# Workflow git — portfolio

> Règle racine : chargée à chaque session, elle régit les gestes de tous les
> dépôts du portfolio.

## Identité — tenue par une garde

Tous les commits du portfolio portent l'identité **personnelle** :
`Amissan Boris-David Amoussou-Guenou <amissan.ag@outlook.fr>`.

**Aucune mention d'un compte ou d'un domaine employeur**, nulle part : ni auteur,
ni message, ni contenu. Ces dépôts sont publics et l'historique est irréversible.

Ce n'est pas de la discipline : `.githooks/pre-commit` **refuse** le commit dont
l'auteur diverge, et refuse tout contenu indexé portant un marqueur d'employeur ou
une valeur de secret. Le hook est versionné (`core.hooksPath`), donc il survit à
un clone — contrairement à un `includeIf` global, qui dépend du chemin machine.

## Branches

`main` est la branche livrée. Le travail se fait sur une branche dédiée, jamais
directement sur `main`.

| Préfixe | Usage |
|---|---|
| `feat/` | nouvelle fonctionnalité |
| `fix/` | correction |
| `refactor/` | restructuration sans changement de comportement |
| `docs/` | documentation seule |
| `chore/` | outillage, CI, dépendances |

Minuscules, tirets, pas d'accents.

## Commits

Format `type(scope): description`, description en français, à l'impératif présent,
première ligne ≤ 72 caractères, sans point final.

**Types** : `feat` · `fix` · `refactor` · `perf` · `test` · `docs` · `chore`
**Scopes** : `web` · `ios` · `api` · `hub` · `ci` · `design` · `content`

Un commit = un changement cohérent. Un message dit **pourquoi**, pas quoi — le
diff dit déjà quoi.

## Avant de pousser

Build, lint et suite de tests **complète** verts, **vérifiés dans les logs** —
jamais sur le code de retour d'un pipe, qui rend celui de la dernière commande.
Un test qui échoue se dit, avec sa sortie.

> ⚠️ Rien n'exécute cette dernière section aujourd'hui : c'est de la discipline,
> pas une garde. Elle le deviendra quand chaque dépôt aura sa CI — et cette ligne
> disparaîtra alors, parce qu'une règle qui ment sur ce qui la tient est pire que
> pas de règle.
