# 0001 — Quatre dépôts plutôt qu'un monorepo

**Statut** : Accepté · **Date** : 2026-09-13

## Contexte

Le portfolio se décline en trois produits — une web app, une app iOS native, une
API — qui partagent une identité visuelle et un contenu. Ces dépôts sont
**publics** : ils ne sont pas seulement un moyen de livrer, ils sont eux-mêmes
l'objet exposé. Un recruteur ou un lead technique ouvrira `portfolio-ios` et
jugera ce qu'il y lit, sans contexte extérieur.

Deux artefacts n'appartiennent à aucun des trois en propre : le **contrat d'URL**
des deep links (le web produit des liens que l'app doit résoudre) et le **schéma
de contenu** (l'API publie, les deux clients consomment).

## Décision

Quatre dépôts, plus un cinquième pour la signature :

| Dépôt | Visibilité | Contenu |
|---|---|---|
| `portfolio` | public | ADR, contrat de deep links, schéma de contenu, tokens de design, setup d'agents transverse. **Aucun code applicatif.** |
| `portfolio-web` | public | La web app |
| `portfolio-ios` | public | L'app native |
| `portfolio-api` | public | L'API et le contenu |
| `portfolio-certificates` | privé | Stockage `fastlane match` |

## Conséquences

**Ce qu'on gagne.** Chaque dépôt se lit seul : un lecteur qui n'ouvre que
`portfolio-ios` y trouve son `CLAUDE.md`, ses règles, sa CI et son histoire, sans
avoir à comprendre les deux autres. Les cycles de release sont indépendants — une
correction de contenu ne rejoue pas la CI iOS. Et les instructions d'agent restent
scopées : une session ouverte sur le web ne charge rien d'iOS.

**Ce que ça coûte.** Un changement transverse (un champ ajouté au contenu)
traverse deux à trois dépôts et donc deux à trois PR. C'est le prix assumé : ce
coût est **visible** et force à traiter le contrat comme un contrat, là où un
monorepo l'aurait rendu invisible en laissant un commit unique casser
silencieusement le client qu'on n'a pas relancé.

**Ce qu'il faut tenir.** Le hub ne doit jamais devenir un dépotoir : s'il accueille
du code applicatif, il redevient un monorepo mal découpé. Le critère d'admission
est unique — **appartenir à au moins deux dépôts à la fois**.

## Alternatives écartées

**Monorepo.** Atomicité des changements transverses, outillage unique. Écarté
parce que la lisibilité individuelle prime ici : ces dépôts sont des pièces
d'exposition, et un monorepo oblige le lecteur à traverser trois stacks pour juger
une seule. La CI devient aussi un exercice de filtrage par chemins, sans bénéfice
pour un projet à un seul contributeur.

**Trois dépôts sans hub.** Écarté : le contrat de deep links et le schéma de
contenu se seraient dupliqués. Un contrat dupliqué dérive — c'est une question de
temps, pas de discipline.
